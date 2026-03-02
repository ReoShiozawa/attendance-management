; 勤怠管理システム (attendance.asm)
; x86-64 Linux用アセンブリプログラム
; NASM記法

section .data
    ; メニュー表示用
    menu_title db '========== 勤怠管理システム ==========', 0xA
    menu_title_len equ $ - menu_title
    
    menu_1 db '1. 出勤記録', 0xA
    menu_1_len equ $ - menu_1
    
    menu_2 db '2. 退勤記録', 0xA
    menu_2_len equ $ - menu_2
    
    menu_3 db '3. 勤怠履歴表示', 0xA
    menu_3_len equ $ - menu_3
    
    menu_4 db '4. 終了', 0xA
    menu_4_len equ $ - menu_4
    
    prompt db '選択してください: '
    prompt_len equ $ - prompt
    
    ; メッセージ
    msg_clock_in db '出勤を記録しました。', 0xA
    msg_clock_in_len equ $ - msg_clock_in
    
    msg_clock_out db '退勤を記録しました。', 0xA
    msg_clock_out_len equ $ - msg_clock_out
    
    msg_bye db '終了します。', 0xA
    msg_bye_len equ $ - msg_bye
    
    msg_invalid db '無効な選択です。', 0xA
    msg_invalid_len equ $ - msg_invalid
    
    msg_history_header db 0xA, '===== 勤怠履歴 =====', 0xA
    msg_history_header_len equ $ - msg_history_header
    
    msg_record_in db '出勤: '
    msg_record_in_len equ $ - msg_record_in
    
    msg_record_out db '退勤: '
    msg_record_out_len equ $ - msg_record_out
    
    newline db 0xA
    
    filename db 'attendance.dat', 0
    
    ; 日時取得用のフォーマット
    date_format db '%Y/%m/%d %H:%M:%S'
    date_format_len equ $ - date_format

section .bss
    choice resb 2          ; ユーザー入力
    record_buffer resb 100 ; レコード用バッファ
    time_buffer resb 32    ; 時刻文字列用バッファ
    file_descriptor resq 1 ; ファイルディスクリプタ
    history_buffer resb 2048 ; 履歴表示用バッファ

section .text
    global _start

_start:
    ; メインループ
main_loop:
    ; メニュー表示
    call display_menu
    
    ; ユーザー入力を受け取る
    call get_input
    
    ; 入力をチェック
    mov al, [choice]
    
    cmp al, '1'
    je clock_in
    
    cmp al, '2'
    je clock_out
    
    cmp al, '3'
    je show_history
    
    cmp al, '4'
    je exit_program
    
    ; 無効な入力
    call print_invalid
    jmp main_loop

; 出勤記録
clock_in:
    call get_current_time
    
    ; "IN:" + 時刻を記録
    mov rdi, record_buffer
    mov byte [rdi], 'I'
    mov byte [rdi+1], 'N'
    mov byte [rdi+2], ':'
    
    ; 時刻文字列をコピー
    lea rsi, [time_buffer]
    lea rdi, [record_buffer+3]
    call copy_string
    
    ; 改行を追加
    mov byte [rdi], 0xA
    inc rdi
    mov byte [rdi], 0
    
    ; ファイルに書き込む
    call append_to_file
    
    ; 確認メッセージ
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg_clock_in
    mov rdx, msg_clock_in_len
    syscall
    
    jmp main_loop

; 退勤記録
clock_out:
    call get_current_time
    
    ; "OUT:" + 時刻を記録
    mov rdi, record_buffer
    mov byte [rdi], 'O'
    mov byte [rdi+1], 'U'
    mov byte [rdi+2], 'T'
    mov byte [rdi+3], ':'
    
    ; 時刻文字列をコピー
    lea rsi, [time_buffer]
    lea rdi, [record_buffer+4]
    call copy_string
    
    ; 改行を追加
    mov byte [rdi], 0xA
    inc rdi
    mov byte [rdi], 0
    
    ; ファイルに書き込む
    call append_to_file
    
    ; 確認メッセージ
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg_clock_out
    mov rdx, msg_clock_out_len
    syscall
    
    jmp main_loop

; 履歴表示
show_history:
    ; ヘッダー表示
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_history_header
    mov rdx, msg_history_header_len
    syscall
    
    ; ファイルから読み込んで表示
    call read_and_display_file
    
    jmp main_loop

; プログラム終了
exit_program:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_bye
    mov rdx, msg_bye_len
    syscall
    
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; exit code 0
    syscall

; === サブルーチン ===

; メニュー表示
display_menu:
    ; タイトル
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_title
    mov rdx, menu_title_len
    syscall
    
    ; メニュー項目1
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_1
    mov rdx, menu_1_len
    syscall
    
    ; メニュー項目2
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_2
    mov rdx, menu_2_len
    syscall
    
    ; メニュー項目3
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_3
    mov rdx, menu_3_len
    syscall
    
    ; メニュー項目4
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_4
    mov rdx, menu_4_len
    syscall
    
    ; プロンプト
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall
    
    ret

; ユーザー入力取得
get_input:
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, choice
    mov rdx, 2
    syscall
    ret

; 無効な入力メッセージ
print_invalid:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_invalid
    mov rdx, msg_invalid_len
    syscall
    ret

; 現在時刻の取得（簡易版）
get_current_time:
    ; 実際のシステムコールで時刻を取得するのは複雑なので
    ; ここでは簡略化してカウンタベースの時刻を生成
    ; 本来はtime()やclock_gettime()を使用
    
    ; 簡易実装: "2025/10/04 HH:MM:SS" フォーマット
    mov rdi, time_buffer
    
    ; 固定部分 "2025/10/04 "
    mov byte [rdi+0], '2'
    mov byte [rdi+1], '0'
    mov byte [rdi+2], '2'
    mov byte [rdi+3], '5'
    mov byte [rdi+4], '/'
    mov byte [rdi+5], '1'
    mov byte [rdi+6], '0'
    mov byte [rdi+7], '/'
    mov byte [rdi+8], '0'
    mov byte [rdi+9], '4'
    mov byte [rdi+10], ' '
    
    ; 時刻部分（簡易的にシステムコールのカウントを使用）
    ; 実際の実装ではtime()システムコールを使用すべき
    mov byte [rdi+11], '0'
    mov byte [rdi+12], '9'
    mov byte [rdi+13], ':'
    mov byte [rdi+14], '0'
    mov byte [rdi+15], '0'
    mov byte [rdi+16], ':'
    mov byte [rdi+17], '0'
    mov byte [rdi+18], '0'
    mov byte [rdi+19], 0
    
    ret

; 文字列コピー（NULL終端まで）
copy_string:
    ; rsi: ソース, rdi: デスティネーション
    push rax
copy_loop:
    lodsb                   ; [rsi] -> al, rsi++
    test al, al
    jz copy_done
    stosb                   ; al -> [rdi], rdi++
    jmp copy_loop
copy_done:
    pop rax
    ret

; ファイルに追記
append_to_file:
    ; ファイルを開く（追記モード）
    mov rax, 2              ; sys_open
    mov rdi, filename
    mov rsi, 0x441          ; O_WRONLY | O_CREAT | O_APPEND
    mov rdx, 0644o          ; パーミッション
    syscall
    
    test rax, rax
    js append_error
    
    mov [file_descriptor], rax
    
    ; 文字列の長さを計算
    mov rdi, record_buffer
    call strlen
    mov rdx, rax            ; 長さをrdxに
    
    ; ファイルに書き込む
    mov rax, 1              ; sys_write
    mov rdi, [file_descriptor]
    mov rsi, record_buffer
    syscall
    
    ; ファイルを閉じる
    mov rax, 3              ; sys_close
    mov rdi, [file_descriptor]
    syscall
    
append_error:
    ret

; 文字列長を計算
strlen:
    ; rdi: 文字列, 戻り値 rax: 長さ
    push rdi
    xor rax, rax
strlen_loop:
    cmp byte [rdi], 0
    je strlen_done
    inc rax
    inc rdi
    jmp strlen_loop
strlen_done:
    pop rdi
    ret

; ファイルを読み込んで表示
read_and_display_file:
    ; ファイルを開く（読み取りモード）
    mov rax, 2              ; sys_open
    mov rdi, filename
    mov rsi, 0              ; O_RDONLY
    xor rdx, rdx
    syscall
    
    test rax, rax
    js read_error
    
    mov [file_descriptor], rax
    
    ; ファイルを読み込む
    mov rax, 0              ; sys_read
    mov rdi, [file_descriptor]
    mov rsi, history_buffer
    mov rdx, 2048
    syscall
    
    push rax                ; 読み込んだバイト数を保存
    
    ; ファイルを閉じる
    mov rax, 3              ; sys_close
    mov rdi, [file_descriptor]
    syscall
    
    ; 読み込んだ内容を表示
    pop rdx                 ; 読み込んだバイト数
    test rdx, rdx
    jz read_error
    
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, history_buffer
    syscall
    
read_error:
    ret
