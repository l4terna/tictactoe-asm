section .data
    board   db  '1','2','3'
            db  '4','5','6'
            db  '7','8','9'
    
    current_player db 'X'

    clear_screen db 27,"[H",27,"[2J",27,"[3J",0
    clear_screen_len equ $ - clear_screen
    
    horizontal_line db '-------------', 10, 0
    vertical_line   db '|', 0
    newline        db 10, 0
    space          db ' ', 0
    
    prompt_move    db 'Player ', 0
    prompt_turn    db "'s turn (1-9): ", 0
    invalid_move   db 'Invalid move! Try again.', 10, 0
    game_draw      db 'Game is a draw!', 10, 0
    game_won       db 'Player ', 0
    won_msg        db ' wins!', 10, 0
    
    buffer        times 2 db 0

section .bss
    game_finished resb 1

section .text
    global _start

is_cell_occupied:
    dec rdi
    movzx rax, byte [board + rdi]
    sub rax, '0'
    cmp rax, 1
    jl .occupied
    cmp rax, 9
    jg .occupied
    mov al, 1
    ret
.occupied:
    xor al, al
    ret

set_mark:
    dec rdi
    mov byte [board + rdi], sil
    ret

switch_player:
    cmp byte [current_player], 'X'
    je .set_o
    mov byte [current_player], 'X'
    jmp .done
.set_o:
    mov byte [current_player], 'O'
.done:
    ret

draw_board:
    push rbp
    mov rbp, rsp
    mov rcx, 3
    mov rbx, 0

.draw_row:
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, horizontal_line
    mov rdx, 14
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, vertical_line
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    lea rsi, [board + rbx]
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, vertical_line
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    lea rsi, [board + rbx + 1]
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, vertical_line
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    lea rsi, [board + rbx + 2]
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, vertical_line
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    add rbx, 3
    pop rcx
    dec rcx
    jnz .draw_row

    mov rax, 1
    mov rdi, 1
    mov rsi, horizontal_line
    mov rdx, 14
    syscall

    mov rsp, rbp
    pop rbp
    ret

check_win:
    mov rcx, 3
    mov rbx, 0
.check_horizontal:
    mov al, [board + rbx]
    cmp al, ' '
    je .next_row
    cmp al, [board + rbx + 1]
    jne .next_row
    cmp al, [board + rbx + 2]
    jne .next_row
    mov al, 1
    ret
.next_row:
    add rbx, 3
    dec rcx
    jnz .check_horizontal

    mov rcx, 3
    mov rbx, 0
.check_vertical:
    mov al, [board + rbx]
    cmp al, ' '
    je .next_col
    cmp al, [board + rbx + 3]
    jne .next_col
    cmp al, [board + rbx + 6]
    jne .next_col
    mov al, 1
    ret
.next_col:
    inc rbx
    dec rcx
    jnz .check_vertical

    mov al, [board]
    cmp al, ' '
    je .check_diag2
    cmp al, [board + 4]
    jne .check_diag2
    cmp al, [board + 8]
    jne .check_diag2
    mov al, 1
    ret

.check_diag2:
    mov al, [board + 2]
    cmp al, ' '
    je .no_win
    cmp al, [board + 4]
    jne .no_win
    cmp al, [board + 6]
    jne .no_win
    mov al, 1
    ret

.no_win:
    xor al, al
    ret

check_draw:
    mov rcx, 9
    mov rbx, 0
.check_cell:
    movzx rax, byte [board + rbx]
    sub rax, '0'
    cmp rax, 1
    jl .next_cell
    cmp rax, 9
    jle .not_draw
.next_cell:
    inc rbx
    dec rcx
    jnz .check_cell
    mov al, 1
    ret
.not_draw:
    xor al, al
    ret

_start:
    mov byte [game_finished], 0
    call clear_terminal
    jmp game_loop

clear_terminal:
    push rbp
    mov rbp, rsp
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, clear_screen_len
    syscall
    mov rsp, rbp
    pop rbp
    ret

game_loop:
    call clear_terminal
    call draw_board

    cmp byte [game_finished], 1
    je exit_game

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_move
    mov rdx, 7
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, current_player
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_turn
    mov rdx, 14
    syscall
    
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 2
    syscall
    
    mov al, [buffer]
    sub al, '0'
    cmp al, 1
    jl invalid_input
    cmp al, 9
    jg invalid_input
    
    movzx rdi, al
    call is_cell_occupied
    test al, al
    jz invalid_input
    
    movzx rdi, byte [buffer]
    sub rdi, '0'
    mov sil, [current_player]
    call set_mark
    
    call check_win
    test al, al
    jnz winner_found
    
    call check_draw
    test al, al
    jnz draw_found
    
    call switch_player
    jmp game_loop

invalid_input:
    call clear_terminal
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_move
    mov rdx, 24
    syscall
    jmp game_loop

winner_found:
    call clear_terminal
    call draw_board
    
    mov rax, 1
    mov rdi, 1
    mov rsi, game_won
    mov rdx, 7
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, current_player
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, won_msg
    mov rdx, 7
    syscall
    
    mov byte [game_finished], 1
    jmp exit_game

draw_found:
    call clear_terminal
    call draw_board
    
    mov rax, 1
    mov rdi, 1
    mov rsi, game_draw
    mov rdx, 15
    syscall
    
    mov byte [game_finished], 1
    jmp exit_game

exit_game:
    mov rax, 60
    xor rdi, rdi
    syscall