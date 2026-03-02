// 勤怠管理システム (attendance.s)
// ARM64 (AArch64) Linux用アセンブリプログラム
// GNU Assembler記法

.data
    // メニュー表示用
    menu_title:     .asciz "========== 勤怠管理システム ==========\n"
    menu_1:         .asciz "1. 出勤記録\n"
    menu_2:         .asciz "2. 退勤記録\n"
    menu_3:         .asciz "3. 勤怠履歴表示\n"
    menu_4:         .asciz "4. 終了\n"
    prompt:         .asciz "選択してください: "
    
    // メッセージ
    msg_clock_in:   .asciz "出勤を記録しました。\n"
    msg_clock_out:  .asciz "退勤を記録しました。\n"
    msg_bye:        .asciz "終了します。\n"
    msg_invalid:    .asciz "無効な選択です。\n"
    msg_history_header: .asciz "\n===== 勤怠履歴 =====\n"
    
    filename:       .asciz "attendance.dat"
    
    // レコードフォーマット
    record_in_fmt:  .asciz "IN:2025/10/04 %02d:%02d:%02d\n"
    record_out_fmt: .asciz "OUT:2025/10/04 %02d:%02d:%02d\n"

.bss
    .align 4
    choice:         .skip 4
    record_buffer:  .skip 128
    time_buffer:    .skip 32
    history_buffer: .skip 2048
    time_counter:   .skip 4

.text
.align 2
.global _start

_start:
    // 時間カウンターの初期化
    adr x0, time_counter
    mov w1, #0
    str w1, [x0]

main_loop:
    // メニュー表示
    bl display_menu
    
    // ユーザー入力を受け取る
    bl get_input
    
    // 入力をチェック
    adr x0, choice
    ldrb w0, [x0]
    
    cmp w0, #'1'
    b.eq clock_in
    
    cmp w0, #'2'
    b.eq clock_out
    
    cmp w0, #'3'
    b.eq show_history
    
    cmp w0, #'4'
    b.eq exit_program
    
    // 無効な入力
    bl print_invalid
    b main_loop

// 出勤記録
clock_in:
    // "IN:2025/10/04 HH:MM:SS\n" を生成
    bl get_current_time
    
    // record_bufferに記録を作成
    adr x0, record_buffer
    adr x1, record_in_fmt
    
    // 簡易的な時刻文字列を作成
    mov x1, #'I'
    strb w1, [x0], #1
    mov x1, #'N'
    strb w1, [x0], #1
    mov x1, #':'
    strb w1, [x0], #1
    mov x1, #'2'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    strb w1, [x0], #1
    mov x1, #'2'
    strb w1, [x0], #1
    mov x1, #'5'
    strb w1, [x0], #1
    mov x1, #'/'
    strb w1, [x0], #1
    mov x1, #'1'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    mov x1, #'/'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    mov x1, #'4'
    strb w1, [x0], #1
    mov x1, #' '
    strb w1, [x0], #1
    
    // 時刻部分を追加
    adr x1, time_buffer
    mov x2, #20
copy_time_in:
    ldrb w3, [x1], #1
    strb w3, [x0], #1
    subs x2, x2, #1
    b.ne copy_time_in
    
    // ファイルに書き込む
    bl append_to_file
    
    // 確認メッセージ
    adr x1, msg_clock_in
    bl print_string
    
    b main_loop

// 退勤記録
clock_out:
    // "OUT:2025/10/04 HH:MM:SS\n" を生成
    bl get_current_time
    
    adr x0, record_buffer
    mov x1, #'O'
    strb w1, [x0], #1
    mov x1, #'U'
    strb w1, [x0], #1
    mov x1, #'T'
    strb w1, [x0], #1
    mov x1, #':'
    strb w1, [x0], #1
    mov x1, #'2'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    strb w1, [x0], #1
    mov x1, #'2'
    strb w1, [x0], #1
    mov x1, #'5'
    strb w1, [x0], #1
    mov x1, #'/'
    strb w1, [x0], #1
    mov x1, #'1'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    mov x1, #'/'
    strb w1, [x0], #1
    mov x1, #'0'
    strb w1, [x0], #1
    mov x1, #'4'
    strb w1, [x0], #1
    mov x1, #' '
    strb w1, [x0], #1
    
    // 時刻部分を追加
    adr x1, time_buffer
    mov x2, #20
copy_time_out:
    ldrb w3, [x1], #1
    strb w3, [x0], #1
    subs x2, x2, #1
    b.ne copy_time_out
    
    // ファイルに書き込む
    bl append_to_file
    
    // 確認メッセージ
    adr x1, msg_clock_out
    bl print_string
    
    b main_loop

// 履歴表示
show_history:
    // ヘッダー表示
    adr x1, msg_history_header
    bl print_string
    
    // ファイルから読み込んで表示
    bl read_and_display_file
    
    b main_loop

// プログラム終了
exit_program:
    adr x1, msg_bye
    bl print_string
    
    mov x0, #0              // exit code
    mov x8, #93             // sys_exit
    svc #0

// === サブルーチン ===

// メニュー表示
display_menu:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    adr x1, menu_title
    bl print_string
    
    adr x1, menu_1
    bl print_string
    
    adr x1, menu_2
    bl print_string
    
    adr x1, menu_3
    bl print_string
    
    adr x1, menu_4
    bl print_string
    
    adr x1, prompt
    bl print_string
    
    ldp x29, x30, [sp], #16
    ret

// 文字列を表示（x1 = 文字列アドレス）
print_string:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    mov x2, x1              // 文字列の先頭を保存
    mov x3, #0              // 長さカウンター
strlen_loop:
    ldrb w4, [x1], #1
    cbz w4, strlen_done
    add x3, x3, #1
    b strlen_loop
    
strlen_done:
    mov x0, #1              // stdout
    mov x1, x2              // 文字列
    mov x2, x3              // 長さ
    mov x8, #64             // sys_write
    svc #0
    
    ldp x29, x30, [sp], #16
    ret

// ユーザー入力取得
get_input:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    mov x0, #0              // stdin
    adr x1, choice
    mov x2, #4
    mov x8, #63             // sys_read
    svc #0
    
    ldp x29, x30, [sp], #16
    ret

// 無効な入力メッセージ
print_invalid:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    adr x1, msg_invalid
    bl print_string
    
    ldp x29, x30, [sp], #16
    ret

// 現在時刻の取得（簡易版）
get_current_time:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // time_counterをインクリメント
    adr x0, time_counter
    ldr w1, [x0]
    add w1, w1, #1
    str w1, [x0]
    
    // 簡易的な時刻を生成 "09:00:00\n"
    adr x2, time_buffer
    
    // 時
    mov w3, #'0'
    strb w3, [x2], #1
    mov w3, #'9'
    strb w3, [x2], #1
    mov w3, #':'
    strb w3, [x2], #1
    
    // 分（カウンターの下位桁を使用）
    mov w3, w1
    and w3, w3, #0x3F
    mov w5, #10
    udiv w4, w3, w5
    add w4, w4, #'0'
    strb w4, [x2], #1
    
    msub w4, w4, w5, w3
    sub w4, w3, w4
    add w4, w4, #'0'
    strb w4, [x2], #1
    mov w3, #':'
    strb w3, [x2], #1
    
    // 秒（カウンターを使用）
    and w3, w1, #0x3F
    mov w5, #10
    udiv w4, w3, w5
    add w4, w4, #'0'
    strb w4, [x2], #1
    
    msub w4, w4, w5, w3
    sub w4, w3, w4
    add w4, w4, #'0'
    strb w4, [x2], #1
    
    mov w3, #'\n'
    strb w3, [x2], #1
    mov w3, #0
    strb w3, [x2]
    
    ldp x29, x30, [sp], #16
    ret

// ファイルに追記
append_to_file:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    
    // ファイルを開く（追記モード）
    mov x0, #-100           // AT_FDCWD
    adr x1, filename
    mov x2, #0x441          // O_WRONLY | O_CREAT | O_APPEND
    mov x3, #0644           // パーミッション
    mov x8, #56             // sys_openat
    svc #0
    
    cmp x0, #0
    b.lt append_error
    str x0, [sp, #16]       // fdを保存
    
    // record_bufferの長さを計算
    adr x1, record_buffer
    mov x2, #0
calc_len:
    ldrb w3, [x1, x2]
    cbz w3, len_done
    add x2, x2, #1
    cmp x2, #128
    b.lt calc_len
    
len_done:
    // ファイルに書き込む
    ldr x0, [sp, #16]       // fd
    adr x1, record_buffer
    mov x8, #64             // sys_write
    svc #0
    
    // ファイルを閉じる
    ldr x0, [sp, #16]       // fd
    mov x8, #57             // sys_close
    svc #0
    
append_error:
    ldp x29, x30, [sp], #32
    ret

// ファイルを読み込んで表示
read_and_display_file:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    
    // ファイルを開く（読み取りモード）
    mov x0, #-100           // AT_FDCWD
    adr x1, filename
    mov x2, #0              // O_RDONLY
    mov x3, #0
    mov x8, #56             // sys_openat
    svc #0
    
    cmp x0, #0
    b.lt read_error
    str x0, [sp, #16]       // fdを保存
    
    // ファイルを読み込む
    ldr x0, [sp, #16]       // fd
    adr x1, history_buffer
    mov x2, #2048
    mov x8, #63             // sys_read
    svc #0
    
    str x0, [sp, #24]       // 読み込んだバイト数を保存
    
    // ファイルを閉じる
    ldr x0, [sp, #16]       // fd
    mov x8, #57             // sys_close
    svc #0
    
    // 読み込んだ内容を表示
    ldr x2, [sp, #24]       // 読み込んだバイト数
    cmp x2, #0
    b.le read_error
    
    mov x0, #1              // stdout
    adr x1, history_buffer
    mov x8, #64             // sys_write
    svc #0
    
read_error:
    ldp x29, x30, [sp], #32
    ret
