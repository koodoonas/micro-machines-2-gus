; Micro Machines 2 GF1 hardware audio patcher v1.0. Original implementation, no game code.
; Build: nasm -f bin MM2GUS.ASM -o MM2GUS.COM
bits 16
org 100h

start:
    push cs
    pop ds
    cld
    mov si,80h
    mov cl,[si]
    xor ch,ch
    jcxz install
.arg:
    inc si
    cmp byte [si],' '
    je .arg
    cmp byte [si],'/'
    jne help
    inc si
    mov al,[si]
    and al,0dfh
    cmp al,'U'
    je uninstall
    jmp help

install:
    mov dx,exe_name
    call check_exe
    jc failure
    cmp byte [version],3
    je already
    cmp byte [version],0
    jne upgrade
    mov dx,exe_old
    call absent
    jc backups_exist
    mov dx,sound_old
    call absent
    jc backups_exist
    mov si,exe_name
    mov di,exe_old
    call copy_file
    jc failure
    mov si,sound_name
    mov di,sound_old
    call copy_file
    jc failure
    jmp patch
upgrade:
    mov dx,exe_old
    call check_exe
    jc failure
    cmp byte [version],0
    jne failure
    mov dx,sound_old
    call exists
    jc failure
patch:
    mov dx,exe_name
    mov ax,3d02h
    int 21h
    jc failure
    mov [handle],ax
    ; Reapplying 02 to the two selectors also works during v0.1 upgrade.
    mov dx,04c0b3h & 0ffffh
    mov cx,04c0b3h >> 16
    mov si,selector
    mov bx,1
    call write_at
    jc patch_fail
    mov dx,04c2e7h & 0ffffh
    mov cx,04c2e7h >> 16
    mov si,selector
    mov bx,1
    call write_at
    jc patch_fail
    mov dx,060d00h & 0ffffh
    mov cx,060d00h >> 16
    mov si,dma_stub
    mov bx,dma_stub_end-dma_stub
    call write_at
    jc patch_fail
    mov dx,062b7eh & 0ffffh
    mov cx,062b7eh >> 16
    mov si,block_size
    mov bx,4
    call write_at
    jc patch_fail
    mov dx,08d4b8h & 0ffffh
    mov cx,08d4b8h >> 16
    mov si,block_size
    mov bx,4
    call write_at
    jc patch_fail
    mov dx,0ca4eh
    mov cx,02h
    mov si,timer_patch_0
    mov bx,3
    call write_at
    jc patch_fail
    mov dx,0682h
    mov cx,06h
    mov si,timer_patch_1
    mov bx,3
    call write_at
    jc patch_fail
    mov dx,0687h
    mov cx,06h
    mov si,timer_patch_2
    mov bx,6
    call write_at
    jc patch_fail
    mov dx,09ach
    mov cx,06h
    mov si,timer_patch_3
    mov bx,5
    call write_at
    jc patch_fail
    mov dx,09d9h
    mov cx,06h
    mov si,timer_patch_4
    mov bx,5
    call write_at
    jc patch_fail
    mov dx,0b74h
    mov cx,06h
    mov si,timer_patch_5
    mov bx,10
    call write_at
    jc patch_fail
    mov dx,07215h
    mov cx,06h
    mov si,timer_patch_6
    mov bx,4
    call write_at
    jc patch_fail
    mov dx,0721bh
    mov cx,06h
    mov si,timer_patch_7
    mov bx,5
    call write_at
    jc patch_fail
    call close_handle
    mov dx,sound_name
    xor cx,cx
    mov ah,3ch
    int 21h
    jc failure
    mov [handle],ax
    mov bx,ax
    mov dx,sound_fix
    mov cx,sound_fix_end-sound_fix
    mov ah,40h
    int 21h
    jc patch_fail
    cmp ax,cx
    jne patch_fail
    call close_handle
verify:
    mov dx,exe_name
    call check_exe
    jc failure
    cmp byte [version],3
    jne failure
    mov dx,msg_done
    jmp success
patch_fail:
    call close_handle
    jmp failure

uninstall:
    mov dx,exe_name
    call check_exe
    jc failure
    cmp byte [version],0
    je already
    mov dx,exe_old
    call check_exe
    jc failure
    cmp byte [version],0
    jne failure
    mov dx,sound_old
    call exists
    jc failure
    mov si,exe_old
    mov di,exe_name
    call copy_file
    jc failure
    mov si,sound_old
    mov di,sound_name
    call copy_file
    jc failure
    mov dx,msg_restored
    jmp success

help:
    mov dx,msg_help
    jmp success
already:
    mov dx,msg_already
    jmp success
backups_exist:
    mov dx,msg_backups
    jmp error_msg
failure:
    mov dx,msg_failed
error_msg:
    mov ah,9
    int 21h
    mov ax,4c01h
    int 21h
success:
    mov ah,9
    int 21h
    mov ax,4c00h
    int 21h

; CF set if an existing file was opened.
absent:
    mov ax,3d00h
    int 21h
    jc .clear
    mov bx,ax
    mov ah,3eh
    int 21h
    stc
    ret
.clear:
    clc
    ret
exists:
    mov ax,3d00h
    int 21h
    jc .missing
    mov bx,ax
    mov ah,3eh
    int 21h
    clc
    ret
.missing:
    stc
    ret

; DX:AX seek target is passed as CX:DX. BX byte count, DS:SI payload.
write_at:
    push bx
    push si
    mov bx,[handle]
    mov ax,4200h
    int 21h
    jc .failed
    pop dx
    pop cx
    mov ah,40h
    int 21h
    jc .err
    cmp ax,cx
    jne .err
    clc
    ret
.failed:
    pop si
    pop bx
.err:
    stc
    ret

close_handle:
    mov bx,[handle]
    mov ah,3eh
    int 21h
    ret

; DX filename. Sets version 0 original, 1 v0.1, 2 optimized, CF on error.
check_exe:
    mov ax,3d00h
    int 21h
    jc .error
    mov [handle],ax
    mov bx,ax
    xor cx,cx
    xor dx,dx
    mov ax,4202h
    int 21h
    jc .close_error
    cmp dx,9
    jne .close_error
    cmp ax,02eaeh
    jne .close_error
    xor cx,cx
    xor dx,dx
    mov ax,4200h
    int 21h
    jc .close_error
    mov dword [crc],0ffffffffh
.read:
    mov bx,[handle]
    mov dx,buffer
    mov cx,4096
    mov ah,3fh
    int 21h
    jc .close_error
    or ax,ax
    jz .end
    mov cx,ax
    mov di,buffer
.byte:
    movzx ebx,byte [di]
    mov esi,[crc]
    xor esi,ebx
    mov dl,8
.bit:
    shr esi,1
    jnc .next
    xor esi,0edb88320h
.next:
    dec dl
    jnz .bit
    mov [crc],esi
    inc di
    loop .byte
    jmp .read
.end:
    call close_handle
    mov eax,[crc]
    not eax
    mov byte [version],0
    cmp eax,0b9ff20ech
    je .ok
    mov byte [version],1
    cmp eax,03248c6cfh
    je .ok
    mov byte [version],2
    cmp eax,078b677d7h
    je .ok
    mov byte [version],3
    cmp eax,021152230h
    je .ok
    stc
    ret
.close_error:
    call close_handle
.error:
    stc
    ret
.ok:
    clc
    ret

; DS:SI source, DS:DI destination; truncates destination after source opens.
copy_file:
    mov dx,si
    mov ax,3d00h
    int 21h
    jc .err
    mov [source],ax
    mov dx,di
    xor cx,cx
    mov ah,3ch
    int 21h
    jc .close_source
    mov [target],ax
.read:
    mov bx,[source]
    mov dx,buffer
    mov cx,4096
    mov ah,3fh
    int 21h
    jc .close_both_error
    or ax,ax
    jz .done
    mov cx,ax
    mov bx,[target]
    mov ah,40h
    int 21h
    jc .close_both_error
    cmp ax,cx
    jne .close_both_error
    jmp .read
.done:
    mov bx,[target]
    mov ah,3eh
    int 21h
    mov bx,[source]
    mov ah,3eh
    int 21h
    clc
    ret
.close_both_error:
    mov bx,[target]
    mov ah,3eh
    int 21h
.close_source:
    mov bx,[source]
    mov ah,3eh
    int 21h
.err:
    stc
    ret

exe_name db 'MM2.EXE',0
exe_old db 'MM2.OLD',0
sound_name db 'SOUND.BAT',0
sound_old db 'SOUND.OLD',0
selector db 2
; GF1 DMA upload: source EDX, destination EAX, byte count EBX.
; Existing game DMA routine takes EAX source, EBX destination, ECX count.
dma_stub:
    db 051h,089h,0d9h,089h,0c3h,089h,0d0h,031h,0d2h,06ah,001h,0e8h
    dd 01cd0h
    db 059h,0c3h
dma_stub_end:
block_size dd 4096
sound_fix db '@ECHO OFF',13,10,'INSTALL CFG\E_SOUND.CFG',13,10
sound_fix_end:
msg_done db 'MM2GUS 1.0 hardware audio installed. Original files: MM2.OLD and SOUND.OLD',13,10,'$'
msg_restored db 'Original game files restored; .OLD backups retained.',13,10,'$'
msg_already db 'Already in this state.',13,10,'$'
msg_backups db 'Backup name already exists. Inspect MM2.OLD and SOUND.OLD.',13,10,'$'
msg_failed db 'Unsupported file, missing backup, or DOS file error.',13,10,'Check MM2.OLD and SOUND.OLD before retrying.',13,10,'$'
msg_help db 'Run MM2GUS from the game directory to install; MM2GUS /U restores originals.',13,10,'$'

; Original shared timer patch bytes. Relative branches require no new LE fixups.
timer_patch_0 db 0c3h,0a7h,003h
timer_patch_1 db 0e8h,059h,001h
timer_patch_2 db 061h,0e9h,002h,089h,0fdh,0ffh
timer_patch_3 db 090h,090h,090h,090h,090h
timer_patch_4 db 090h,090h,090h,090h,090h
timer_patch_5 db 0e8h,057h,0fch,0ffh,0ffh,0e9h,004h,0fbh,0ffh,0ffh
timer_patch_6 db 060h,0b8h,095h,042h
timer_patch_7 db 0e9h,054h,099h,0ffh,0ffh

handle dw 0
source dw 0
target dw 0
version db 0
crc dd 0
buffer times 4096 db 0
