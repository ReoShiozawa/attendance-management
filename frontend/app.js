// APIのベースURL（環境に応じて変更）
const API_BASE_URL = 'http://localhost:8000';

// 認証トークンを取得
function getAuthToken() {
    return localStorage.getItem('access_token');
}

// 認証ヘッダーを取得
function getAuthHeaders() {
    const token = getAuthToken();
    return {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    };
}

// ログアウト
function logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('username');
    window.location.href = 'login.html';
}

// ログイン状態をチェック
function checkAuth() {
    const token = getAuthToken();
    if (!token) {
        window.location.href = 'login.html';
        return false;
    }
    return true;
}

// DOM要素
const clockInBtn = document.getElementById('clockInBtn');
const clockOutBtn = document.getElementById('clockOutBtn');
const refreshBtn = document.getElementById('refreshBtn');
const recordsList = document.getElementById('recordsList');
const currentTimeEl = document.getElementById('currentTime');
const currentDateEl = document.getElementById('currentDate');
const messageEl = document.getElementById('message');

// 統計情報の要素
const totalRecordsEl = document.getElementById('totalRecords');
const todayRecordsEl = document.getElementById('todayRecords');
const clockInCountEl = document.getElementById('clockInCount');
const clockOutCountEl = document.getElementById('clockOutCount');

// 現在時刻を更新
function updateCurrentTime() {
    const now = new Date();
    
    const timeStr = now.toLocaleTimeString('ja-JP', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
    
    const dateStr = now.toLocaleDateString('ja-JP', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
    
    currentTimeEl.textContent = timeStr;
    currentDateEl.textContent = dateStr.replace(/\//g, '/');
}

// メッセージを表示
function showMessage(text, type = 'success') {
    messageEl.textContent = text;
    messageEl.className = `message ${type} show`;
    
    setTimeout(() => {
        messageEl.className = 'message';
    }, 3000);
}

// 出勤記録
async function clockIn() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/clock-in`, {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify({
                employee_name: '社員'
            })
        });
        
        if (response.status === 401) {
            showMessage('❌ 認証エラー。再ログインしてください', 'error');
            setTimeout(logout, 2000);
            return;
        }
        
        if (!response.ok) {
            throw new Error('出勤記録に失敗しました');
        }
        
        const data = await response.json();
        showMessage('✅ 出勤を記録しました', 'success');
        
        // データを更新
        await loadRecords();
        await loadStats();
        
    } catch (error) {
        console.error('Error:', error);
        showMessage('❌ エラーが発生しました', 'error');
    }
}

// 退勤記録
async function clockOut() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/clock-out`, {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify({
                employee_name: '社員'
            })
        });
        
        if (response.status === 401) {
            showMessage('❌ 認証エラー。再ログインしてください', 'error');
            setTimeout(logout, 2000);
            return;
        }
        
        if (!response.ok) {
            throw new Error('退勤記録に失敗しました');
        }
        
        const data = await response.json();
        showMessage('✅ 退勤を記録しました', 'success');
        
        // データを更新
        await loadRecords();
        await loadStats();
        
    } catch (error) {
        console.error('Error:', error);
        showMessage('❌ エラーが発生しました', 'error');
    }
}

// 勤怠履歴を読み込み
async function loadRecords() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/records?limit=20`, {
            headers: getAuthHeaders()
        });
        
        if (response.status === 401) {
            logout();
            return;
        }
        
        if (!response.ok) {
            throw new Error('履歴の取得に失敗しました');
        }
        
        const records = await response.json();
        
        // 履歴を表示（新しい順）
        recordsList.innerHTML = '';
        
        if (records.length === 0) {
            recordsList.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">記録がありません</p>';
            return;
        }
        
        records.reverse().forEach(record => {
            const recordEl = document.createElement('div');
            recordEl.className = 'record-item';
            
            const typeClass = record.type === 'IN' ? 'in' : 'out';
            const typeText = record.type === 'IN' ? '出勤' : '退勤';
            const icon = record.type === 'IN' ? '🟢' : '🔴';
            
            recordEl.innerHTML = `
                <span class="record-type ${typeClass}">${icon} ${typeText}</span>
                <div class="record-info">
                    <div class="record-time">${record.timestamp}</div>
                    <div class="record-employee">${record.employee_name}</div>
                </div>
            `;
            
            recordsList.appendChild(recordEl);
        });
        
    } catch (error) {
        console.error('Error:', error);
        recordsList.innerHTML = '<p style="text-align: center; color: #f44336; padding: 20px;">❌ データの読み込みに失敗しました</p>';
    }
}

// 統計情報を読み込み
async function loadStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/stats`, {
            headers: getAuthHeaders()
        });
        
        if (response.status === 401) {
            logout();
            return;
        }
        
        if (!response.ok) {
            throw new Error('統計情報の取得に失敗しました');
        }
        
        const stats = await response.json();
        
        totalRecordsEl.textContent = stats.total_records;
        todayRecordsEl.textContent = stats.today_records;
        clockInCountEl.textContent = stats.clock_in_count;
        clockOutCountEl.textContent = stats.clock_out_count;
        
    } catch (error) {
        console.error('Error:', error);
    }
}

// イベントリスナー
refreshBtn.addEventListener('click', async () => {
    await loadRecords();
    await loadStats();
    showMessage('🔄 データを更新しました', 'success');
});

// イベントリスナーの設定
clockInBtn.addEventListener('click', clockIn);
clockOutBtn.addEventListener('click', clockOut);

// 初期化
async function init() {
    // 認証チェック
    if (!checkAuth()) {
        return;
    }
    
    // ユーザー名を表示
    const username = localStorage.getItem('username');
    const usernameEl = document.getElementById('username');
    if (usernameEl && username) {
        usernameEl.textContent = username;
    }
    
    updateCurrentTime();
    setInterval(updateCurrentTime, 1000);
    
    await loadRecords();
    await loadStats();
    
    // 定期的に自動更新
    setInterval(async () => {
        await loadStats();
    }, 30000); // 30秒ごと
}

// ページ読み込み時に初期化
document.addEventListener('DOMContentLoaded', init);
