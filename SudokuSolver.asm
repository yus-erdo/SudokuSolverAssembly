TITLE Sudoku Solver


.386
.model flat


.data       
sudokuBoard DWORD 1 ; sudokuBoardPointer
posselem DWORD 9 DUP(0) ; possible elements for a position
numposselem DWORD 9 ; number of possible elements
solution_is_possible DWORD 0	; at the beginning a solution is not possible
								; but it is possible when a cell value has found
.code       

public _SolveSudoku

_SolveSudoku PROC ; return void
	push ebp
	mov ebp, esp
	sub esp, 4
	pusha
	
	mov eax, [ebp+8]
	mov sudokuBoard, eax
	
	restart_searching:
	
	mov solution_is_possible, 0
	
	mov ecx, 9
    i_traverse:
        mov [ebp-4], ecx
        mov ecx, 9
        j_traverse:              
            mov edx, [ebp-4]  ; get i
			
			mov eax, ecx
            dec eax ; getCellNum takes zero-based params
            dec edx
            push eax ; param j
            push edx ; param i
            call getCellNum
            ; eax has cell num
            add esp, 8
            
			mov esi, eax
			add esi, sudokuBoard
			mov edx, 0
            cmp [esi], edx 
            jne non_empty_cell_skip_cell
            
            mov edx, [ebp-4]  ; get i           
            push ecx ; param j            
            push edx ; param i
            call solveCell   
            add esp, 8 
            
            cmp solution_is_possible, 1
            je  restart_searching
            
            non_empty_cell_skip_cell:
              
        loop j_traverse
        mov ecx, [ebp-4]
    loop i_traverse
	
    popa 
	mov esp, ebp
	pop ebp
	ret
_SolveSudoku ENDP
     
     
     
     

solveCell PROC ; return void ; param i,j non-zero based   
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.
    sub esp, 8 ; 4 byte local variable for i,j  
    pusha 

        
    mov ebx, [ebp+8]  ; get param i
    mov edx, [ebp+12]  ; get param j
    
    mov [ebp-4], ebx  ; save i to local var i
    mov [ebp-8], edx  ; save j to local var j  
        
    push edx ; param j ; non-zero based params
    push ebx ; param i
    call getRegionNo     
    ;eax has region no
    add esp, 8
    
    push eax ; param regNo //region number
    push edx ; param j
    push ebx ; param i
    call findAndPutValue
    add esp, 12    
    
    
    popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
solveCell ENDP

   
   
   
   
getRegionNo PROC ; return eax //region number //param i,j non-zero based  
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.     
    push ebx
    push edx    
    
    mov ebx, [ebp+8]  ; get param i
    mov edx, [ebp+12]  ; get param j
    
    cmp ebx, 3
    jle first_region_row
    cmp ebx, 6
    jle second_region_row
    cmp ebx, 9
    jle third_region_row
    
    first_region_row:
        cmp edx, 3      
        jle region_1          
        cmp edx, 6     
        jle region_2           
        cmp edx, 9 
        jle region_3
                
        region_1:
            mov eax, 1
            jmp end_func  
        region_2:        
            mov eax, 2
            jmp end_func                
        region_3:            
            mov eax, 3
            jmp end_func  

    second_region_row:
        cmp edx, 3      
        jle region_4          
        cmp edx, 6     
        jle region_5           
        cmp edx, 9 
        jle region_6
                
        region_4:
            mov eax, 4
            jmp end_func  
        region_5:        
            mov eax, 5
            jmp end_func                
        region_6:            
            mov eax, 6
            jmp end_func
            
    third_region_row:
        cmp edx, 3      
        jle region_7          
        cmp edx, 6     
        jle region_8           
        cmp edx, 9 
        jle region_9
                
        region_7:
            mov eax, 7
            jmp end_func  
        region_8:        
            mov eax, 8
            jmp end_func                
        region_9:            
            mov eax, 9
            jmp end_func                        
          
    end_func:    
    pop edx
    pop ebx
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
getRegionNo ENDP  





findAndPutValue PROC ; return void ; param i, j, regNo non-zero based params
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.
    sub esp, 8 ; 2 * 2 byte local variables     
    pusha
    
    mov ebx, [ebp+8]  ; get param i
    mov edx, [ebp+12]  ; get param j
    mov eax, [ebp+16]  ; get param regNo    
    
    call clearPossibilities  
    
    push eax ; param regNo
    call eliminateRegionalPossibilities
    add esp, 4
    
    dec ebx ; make zero based
    push ebx ; i    
    call eliminateRowPossibilities
    add esp, 4
    
    dec edx ; make zero based
    push edx ; j
    call eliminateColPossibilities
    add esp, 4
    
    cmp numposselem, 1 ; if there is only 1 possible value to put
    je value_found   
    jmp skip_cell
    
    value_found:    
    mov ecx, 9
    loop_to_unmarked_value:
        mov ebx, ecx
        dec ebx 
        
        mov [ebp-4], ebx ; save value pos in posselem to local var
        mov esi, OFFSET posselem        
        mov edx, 0
        cmp [esi+ebx*4], edx
        je  assign_value
        jmp skip_value
        
        assign_value:
        mov eax, [ebp+8] ; get i
        mov edx, [ebp+12] ; get j
        
        dec eax ; getCellNum takes zero-based params
        dec edx
        push edx ; param j
        push eax ; param i
        call getCellNum        
        ; eax has cell no
        add esp, 8
        
        mov edx, [ebp-4]
        inc edx
        
        mov esi, 0
        add esi, eax
        add esi, sudokuBoard
        mov [esi], edx
        
        mov solution_is_possible, 1 ; a cell value has found // go on searching
        
        jmp skip_cell
        
        skip_value:
        
    loop loop_to_unmarked_value
    
    skip_cell: 
    
    popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
findAndPutValue ENDP  

           
           


clearPossibilities PROC ; return void    
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.     
	pusha
	
    mov ecx, 9
    clear: 
        mov ebx, ecx
        dec ebx				; make zero based                
        mov esi, OFFSET posselem        
        mov edx, 0
        mov [esi+ebx*4], edx
    loop clear
    
    mov numposselem, 9    
    
	popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
clearPossibilities ENDP  
         
         
         
         

eliminateRegionalPossibilities PROC ; return void ; param regNo
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.     
    sub esp, 16 ; 
    pusha 
    
    mov eax, [ebp+8]  ; get param regNo
            
    ;jump to region no
    cmp eax, 1
    je region_1x
    cmp eax, 2
    je region_2x
    cmp eax, 3
    je region_3x
    cmp eax, 4
    je region_4x
    cmp eax, 5
    je region_5x
    cmp eax, 6
    je region_6x
    cmp eax, 7
    je region_7x
    cmp eax, 8
    je region_8x
    cmp eax, 9
    je region_9x
    
    ;set region [start coordinates - 1]
    region_1x:
    mov edx, 0
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_2x:  
    mov edx, 0  
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 3
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_3x:
    mov edx, 0
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 6
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_4x:
    mov edx, 3
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 0
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_5x:
    mov edx, 3
    mov [ebp-4], edx ; save row to local variable //region start // zero based    
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_6x:
    mov edx, 3
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 6
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_7x:
    mov edx, 6
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 0
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_8x:
    mov edx, 6
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov edx, 3
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg
    
    region_9x:
    mov edx, 6
    mov [ebp-4], edx ; save row to local variable //region start // zero based
    mov [ebp-8], edx ; save col to local variable //region start // zero based
    jmp end_reg    
    end_reg:      
    
          
    mov ecx, 3 ; i
    i_traverse_region:           
        mov [ebp-12], ecx ;save i to local variable
        mov ecx,3 ; j
        j_traverse_region:
            mov ebx, [ebp-12] ; get i
            
            mov eax, [ebp-4] ; get local variable //row no
            mov edx, [ebp-8] ; get local variable //col no
            
            add eax, ebx  ; i
            add edx, ecx  ; j
            dec eax ; to make zero based
            dec edx
                        
            push edx ; param j
            push eax ; param i
            call getCellNum  
            ; eax has cell number
            add esp, 8
            
            mov esi, eax                       
            add esi, sudokuBoard
            mov edx, [esi]
            mov ebx, edx              
            ; ebx has cell value //1-9 possible sudoku values        
            cmp ebx, 0					; cell empty
            je  skip
            
            dec ebx						; make zero based 
                       
            mov esi, OFFSET posselem            
            mov edx, 1					; mark value
            cmp [esi+ebx*4], edx		; value in cell has already found            
            je  skip
            
            
            mov esi, OFFSET posselem
            mov edx, 1
            mov [esi+ebx*4], edx		; mark found value
            dec numposselem
            skip:
            
                       
        loop j_traverse_region
        mov ecx, [ebp-12] ;get i from local variable
    loop i_traverse_region            
                
       
    
    popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
eliminateRegionalPossibilities ENDP 
          
          
          
          

eliminateRowPossibilities PROC ; return void ; param rowNo
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.
    sub esp, 4 ; row num local var     
    pusha
    
    mov ebx, [ebp+8] ; get row num //i zero based
    mov [ebp-4], ebx
    
    mov ecx, 9
    i_traverse_row:        
        mov edx, ecx ; j
        dec edx ; make zero based 
        
        mov ebx, [ebp-4] ; i
        
        push edx ; param j
        push ebx ; param i
        call getCellNum  
        ; eax has cell number
        add esp, 8
        
        mov esi, eax                       
        add esi, sudokuBoard
        mov edx, [esi]
        mov ebx, edx              
        ; ebx has cell value //1-9 possible sudoku values        
        cmp ebx, 0 ; cell empty
        je  skip_2
        
        dec ebx				; make zero based 
        
        mov esi, OFFSET posselem
        mov edx, 1
        cmp [esi+ebx*4], edx ; value in cell has already found
        je  skip_2
                
        mov esi, OFFSET posselem
        mov edx, 1		        
        mov [esi+ebx*4], edx ; mark found value
        dec numposselem
        skip_2:        
        
    
    loop i_traverse_row     
    
    
    popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
eliminateRowPossibilities ENDP 





eliminateColPossibilities PROC ; return void ; param rowNo
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.
    sub esp, 4 ; row num local var     
    pusha
    
    mov ebx, [ebp+8] ; get row num //i zero based
    mov [ebp-4], ebx
    
    mov ecx, 9
    i_traverse_row:        
        mov edx, ecx ; i
        dec edx ; make zero based 
        
        mov ebx, [ebp-4] ; j
        
        push ebx ; param i
        push edx ; param j
        call getCellNum  
        ; eax has cell number
        add esp, 8
        
        mov esi, eax                       
        add esi, sudokuBoard
        mov edx, [esi]
        mov ebx, edx              
        ; ebx has cell value //1-9 possible sudoku values        
        cmp ebx, 0 ; cell empty
        je  skip_2
        
        dec ebx				; make zero based 
        
        mov esi, OFFSET posselem
        mov edx, 1
        cmp [esi+ebx*4], edx ; value in cell has already found
        je  skip_2
                
        mov esi, OFFSET posselem
        mov edx, 1		        
        mov [esi+ebx*4], edx ; mark found value
        dec numposselem
        skip_2:        
        
    
    loop i_traverse_row     
    
    
    popa
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
eliminateColPossibilities ENDP          
          
          
          
          

getCellNum PROC ; return eax ; param i, j zero-based // 4*(i*9+j) = zero based cell number    
    push ebp ; Save the old base pointer value.
    mov ebp, esp ; Set the new base pointer value.     
    push edx 
    push ebx
    
    mov eax, [ebp+8] ; get i     
    
    mov ebx, 0
    mov ebx, 9
    mul ebx
    
    mov edx, [ebp+12] ; get j
    add eax, edx
    mov ebx, 4
    mul ebx  
    
    pop ebx
    pop edx
    mov esp, ebp ; Deallocate local variables
    pop ebp ; Restore the caller’s base pointer value
    ret
getCellNum ENDP 




END      



