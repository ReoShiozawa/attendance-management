"""
勤怠管理システム REST API
FastAPIを使用したバックエンドサービス（認証機能付き）
"""
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import List, Optional
from jose import JWTError, jwt
import bcrypt
import json
import os

# セキュリティ設定
SECRET_KEY = "your-secret-key-change-this-in-production-12345"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

app = FastAPI(title="勤怠管理API", version="2.0.0")

# OAuth2設定
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/login")

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# データファイルのパス
DATA_FILE = "/app/data/attendance.json"
USERS_FILE = "/app/data/users.json"

# モデル定義
class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class UserInDB(User):
    hashed_password: str

class UserRegister(BaseModel):
    username: str
    password: str
    email: Optional[str] = None
    full_name: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class AttendanceRecord(BaseModel):
    id: int
    type: str
    timestamp: str
    employee_name: Optional[str] = "社員"
    username: Optional[str] = None

class ClockRequest(BaseModel):
    employee_name: Optional[str] = "社員"

# ユーティリティ関数
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """パスワードを検証"""
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_password_hash(password: str) -> str:
    """パスワードをハッシュ化"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# ユーザー管理
def init_users_file():
    os.makedirs(os.path.dirname(USERS_FILE), exist_ok=True)
    if not os.path.exists(USERS_FILE):
        default_users = {
            "demo": {
                "username": "demo",
                "full_name": "デモユーザー",
                "email": "demo@example.com",
                "hashed_password": get_password_hash("demo123"),
                "disabled": False
            }
        }
        with open(USERS_FILE, 'w', encoding='utf-8') as f:
            json.dump(default_users, f, ensure_ascii=False, indent=2)

def get_user(username: str):
    init_users_file()
    try:
        with open(USERS_FILE, 'r', encoding='utf-8') as f:
            users = json.load(f)
            if username in users:
                return UserInDB(**users[username])
    except Exception:
        pass
    return None

def save_user(user: UserInDB):
    init_users_file()
    with open(USERS_FILE, 'r', encoding='utf-8') as f:
        users = json.load(f)
    
    users[user.username] = {
        "username": user.username,
        "full_name": user.full_name,
        "email": user.email,
        "hashed_password": user.hashed_password,
        "disabled": user.disabled
    }
    
    with open(USERS_FILE, 'w', encoding='utf-8') as f:
        json.dump(users, f, ensure_ascii=False, indent=2)

def authenticate_user(username: str, password: str):
    user = get_user(username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="認証情報を検証できませんでした",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="無効なユーザーです")
    return current_user

# データファイル管理
def init_data_file():
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    if not os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'w', encoding='utf-8') as f:
            json.dump([], f, ensure_ascii=False)

def read_records() -> List[dict]:
    init_data_file()
    try:
        with open(DATA_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error reading file: {e}")
        return []

def write_records(records: List[dict]):
    init_data_file()
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(records, f, ensure_ascii=False, indent=2)

# エンドポイント
@app.get("/")
def root():
    return {
        "message": "勤怠管理API",
        "version": "2.0.0",
        "endpoints": {
            "ログイン": "POST /api/login",
            "ユーザー登録": "POST /api/register",
            "ユーザー情報": "GET /api/users/me",
            "出勤記録": "POST /api/clock-in",
            "退勤記録": "POST /api/clock-out",
            "履歴取得": "GET /api/records",
            "統計情報": "GET /api/stats"
        }
    }

@app.post("/api/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="ユーザー名またはパスワードが正しくありません",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/api/register", response_model=User)
async def register(user_data: UserRegister):
    existing_user = get_user(user_data.username)
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="このユーザー名は既に使用されています"
        )
    
    hashed_password = get_password_hash(user_data.password)
    new_user = UserInDB(
        username=user_data.username,
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=hashed_password,
        disabled=False
    )
    
    save_user(new_user)
    
    return User(
        username=new_user.username,
        email=new_user.email,
        full_name=new_user.full_name,
        disabled=new_user.disabled
    )

@app.get("/api/users/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@app.post("/api/clock-in", response_model=AttendanceRecord)
async def clock_in(
    request: ClockRequest,
    current_user: User = Depends(get_current_active_user)
):
    records = read_records()
    
    new_record = {
        "id": len(records) + 1,
        "type": "IN",
        "timestamp": datetime.now().strftime("%Y/%m/%d %H:%M:%S"),
        "employee_name": request.employee_name or current_user.full_name,
        "username": current_user.username
    }
    
    records.append(new_record)
    write_records(records)
    
    return new_record

@app.post("/api/clock-out", response_model=AttendanceRecord)
async def clock_out(
    request: ClockRequest,
    current_user: User = Depends(get_current_active_user)
):
    records = read_records()
    
    new_record = {
        "id": len(records) + 1,
        "type": "OUT",
        "timestamp": datetime.now().strftime("%Y/%m/%d %H:%M:%S"),
        "employee_name": request.employee_name or current_user.full_name,
        "username": current_user.username
    }
    
    records.append(new_record)
    write_records(records)
    
    return new_record

@app.get("/api/records")
async def get_records(current_user: User = Depends(get_current_active_user)):
    records = read_records()
    return records

@app.get("/api/stats")
async def get_stats(current_user: User = Depends(get_current_active_user)):
    records = read_records()
    
    total = len(records)
    clock_in_count = sum(1 for r in records if r.get("type") == "IN")
    clock_out_count = sum(1 for r in records if r.get("type") == "OUT")
    
    today = datetime.now().strftime("%Y/%m/%d")
    today_records = sum(1 for r in records if r.get("timestamp", "").startswith(today))
    
    return {
        "total_records": total,
        "today_records": today_records,
        "clock_in_count": clock_in_count,
        "clock_out_count": clock_out_count
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
