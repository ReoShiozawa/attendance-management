// ログイン・登録機能
const API_BASE_URL = 'http://localhost:8000';

let isRegisterMode = false;

// フォームの切り替え
function toggleForm() {
    isRegisterMode = !isRegisterMode;
    const formTitle = document.getElementById('formTitle');
    const submitBtn = document.getElementById('submitBtn');
    const toggleText = document.getElementById('toggleText');
    const toggleLink = document.getElementById('toggleLink');
    const fullNameGroup = document.getElementById('fullNameGroup');
    const emailGroup = document.getElementById('emailGroup');
    
    if (isRegisterMode) {
        formTitle.textContent = '新規登録';
        submitBtn.textContent = '登録';
        submitBtn.className = 'register-btn';
        toggleText.textContent = 'すでにアカウントをお持ちの方は ';
        toggleLink.textContent = 'ログイン';
        fullNameGroup.style.display = 'block';
        emailGroup.style.display = 'block';
    } else {
        formTitle.textContent = 'ログイン';
        submitBtn.textContent = 'ログイン';
        submitBtn.className = 'login-btn';
        toggleText.textContent = 'アカウントをお持ちでない方は ';
        toggleLink.textContent = '新規登録';
        fullNameGroup.style.display = 'none';
        emailGroup.style.display = 'none';
    }
    
    // エラーメッセージをクリア
    hideError();
}

// エラー表示
function showError(message) {
    const errorEl = document.getElementById('errorMessage');
    errorEl.textContent = message;
    errorEl.classList.add('show');
}

function hideError() {
    const errorEl = document.getElementById('errorMessage');
    errorEl.classList.remove('show');
}

// ログイン処理
async function login(username, password) {
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);
    
    const response = await fetch(`${API_BASE_URL}/api/login`, {
        method: 'POST',
        body: formData
    });
    
    if (!response.ok) {
        throw new Error('ログインに失敗しました');
    }
    
    const data = await response.json();
    return data.access_token;
}

// 新規登録処理
async function register(username, password, fullName, email) {
    const response = await fetch(`${API_BASE_URL}/api/register`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: username,
            password: password,
            full_name: fullName || null,
            email: email || null
        })
    });
    
    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || '登録に失敗しました');
    }
    
    return await response.json();
}

// フォーム送信処理
document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    hideError();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const fullName = document.getElementById('fullName').value;
    const email = document.getElementById('email').value;
    
    try {
        if (isRegisterMode) {
            // 新規登録
            await register(username, password, fullName, email);
            showError('登録が完了しました。ログインしてください。');
            
            // ログインフォームに切り替え
            setTimeout(() => {
                toggleForm();
                document.getElementById('username').value = username;
                document.getElementById('password').value = '';
            }, 2000);
            
        } else {
            // ログイン
            const token = await login(username, password);
            
            // トークンを保存
            localStorage.setItem('access_token', token);
            localStorage.setItem('username', username);
            
            // メインページにリダイレクト
            window.location.href = 'index.html';
        }
    } catch (error) {
        showError(error.message);
    }
});

// ページ読み込み時にログイン状態をチェック
window.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('access_token');
    if (token) {
        // すでにログイン済みの場合はメインページへ
        window.location.href = 'index.html';
    }
});
