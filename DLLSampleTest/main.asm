include irvine32.inc
.data
index dword 0
val dword 0 
 grayLevel dword 256 dup (0)
   newgrayLevel dword 256 dup(0)  
   cur dword 0


;no static data
.code
;-----------------------------------------------------
;Sum PROC Calculates 2 unsigned integers
;Recieves: 2 DWord parametes number 1 and number 2
;Return: the sum of the 2 unsigned numbers into the EAX
;------------------------------------------------------
Sum PROC int1:DWORD, int2:DWORD
	mov eax, int1
	add eax, int2
	ret
Sum ENDP

;-----------------------------------------------------
;SumArr PROC Calculates Sum of an array
;Recieves: Offset and the size of an array
;Return: the sum of the array into the EAX
;------------------------------------------------------
SumArr PROC arr:PTR DWORD, sz:DWORD
	push esi
	push ecx

	mov esi, arr
	mov ecx, sz
	mov eax, 0
	sum_loop:
		add eax, DWORD PTR [esi]
		add esi, 4
	loop sum_loop
	
	pop ecx
	pop esi
	Ret
SumArr ENDP

;----------------------------------------------------------------
;Sum PROC convert an array of bytes from lower case to upper case
;Recieves: offset of byte array and it's size
;---------------------------------------------------------------
ToUpper PROC str1:PTR BYTE, sz:DWORD
	push esi
	push ecx
	
	mov esi, str1
	mov ecx, sz
	l1:
		;input validations (Limitation the char to be between a and z)
		cmp byte ptr [esi], 'a'
		jb skip
		cmp byte ptr [esi], 'z'
		ja skip

		and byte ptr [esi], 11011111b
		skip:
		inc esi
	loop l1
	
	pop ecx
	pop esi
	ret
ToUpper ENDP


;#######################################################
;#					Project Procedures					#
;#######################################################



Invert proc redChannel:PTR DWORD, greenChannel:PTR DWORD, blueChannel:PTR DWORD, imageSize: DWORD
	PUSHAD


	MOV ECX, IMAGESIZE
	MOV ESI, REDCHANNEL
	L1:
		MOV EBX, 255
		MOV EAX, [ESI]
		SUB EBX, EAX
		MOV EAX, EBX
		CMP EAX, 0
		JL NEGATIVEVAL1
		
		JMP SKIP1

		NEGATIVEVAL1:
		MOV EAX, 0


		SKIP1:
		MOV [ESI], EAX
		ADD ESI, 4
		
	LOOP L1

		MOV ECX, IMAGESIZE
	MOV ESI, GREENCHANNEL

	L2:
		MOV EBX, 255
		MOV EAX, [ESI]
		SUB EBX, EAX
		MOV EAX, EBX
		CMP EAX, 0
		JL NEGATIVEVAL2
		
		JMP SKIP2

		NEGATIVEVAL2:
		MOV EAX, 0


		SKIP2:
		MOV [ESI], EAX
		ADD ESI, 4
		
	LOOP L2

		MOV ECX, IMAGESIZE
	MOV ESI, BLUECHANNEL

	L3:
		MOV EBX, 255
		MOV EAX, [ESI]
		SUB EBX, EAX
		MOV EAX, EBX
		CMP EAX, 0
		JL NEGATIVEVAL3
		
		JMP SKIP3

		NEGATIVEVAL3:
		MOV EAX, 0


		SKIP3:
		MOV [ESI], EAX
		ADD ESI, 4
		
	LOOP L3

	POPAD
	RET
Invert endp

;/////////////////////////
sobel proc redChannel:PTR sDWORD,greenChannel:PTR sDWORD,height:DWORD,weight: DWORD,imgsize: DWORD,dir: DWORD
	pushad
	mov ecx, imgsize
	mov esi,redChannel
	mov index,0
	mov edx,0
	mov ebx,dir
	cmp ebx,'x'
	je updatex
	updatey :
		mov val ,0
		;--------save values-----------------
		push ecx
		push esi
	
		;-------corner cases--------------
		;-------------first row----------------
		
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
			
		mov edi, height
		mov edx,0
		div edi
		
		cmp edx,0
		je frow
		
		
		;--------------last row-----------
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
		
		mov edi, height
		mov edx,0
		div edi
		dec edi
		cmp edx,edi
		je lrow


		;------first col-----------------
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
		
		cmp eax,height
		
		jb fcol
		
		;------last col-----------
		mov edi,imgsize
		sub edi,height

		cmp eax,edi
		ja lcol

		
		
		
		
		
		
		
		
		;------set esi on index-------------
		mov eax,height
		mov cur,4
		imul cur
		sub esi,eax
		sub esi,4
		;---------imultiplication 1,1 element--------------
		mov eax,1
		imul dword ptr [esi]
		add val,eax
		
		;---------multiplication 1,3 element------------
		add esi,8
		mov eax,-1
		mul dword ptr[esi]
		add val,eax
		
		;---------return original index and save it------------
		pop esi
		push esi
		;--------------mul 2,1-----------------------
		sub esi,4
		mov eax,2
		imul dword ptr [esi]
		add val,eax
		;--------------mul 2,3-----------------------
		add esi,8
		mov eax,-2
		imul dword ptr [esi]
		add val,eax
		;---------return original index and save it------------
		pop esi
		push esi
		;------set esi on index-------------
		mov eax,height
		mov cur,4
		imul cur
		add esi,eax
		sub esi,4
		;-------------multiplication 3,1 element--------
		mov edi,dword ptr [esi]
		add val,edi
		;-------------multiplication 3,3 element----------
		add esi ,8
		mov eax,dword ptr [esi]
		mov cur ,-1
		imul cur
		add val,eax
		jmp forall
		
		


		;-------first column-----------
		fcol:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			add esi,eax
			sub esi,4
			
			;-------------multiplication 3,1 element--------
			mov edi,dword ptr [esi]
			add val,edi
			;-------------multiplication 3,3 element----------
			add esi ,8
			mov eax,dword ptr [esi]
			mov cur ,-1
			imul cur
			add val,eax
			;---------return original index and save it------------
			pop esi
			push esi
			;--------------mul 2,1-----------------------
			sub esi,4
			mov eax,2
			imul dword ptr [esi]
			add val,eax
			;--------------mul 2,3-----------------------
			add esi,8
			mov eax,-2
			imul dword ptr [esi]
			add val,eax
				
			jmp forall
			;------------------last col----------------
		lcol:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			sub esi,4
			;---------multiplication 1,1 element--------------
			mov eax,1
			imul dword ptr [esi]
			add val,eax
			;---------multiplication 1,3 element------------
			add esi,8
			mov eax,-1
			imul dword ptr[esi]
			add val,eax
			;---------return original index and save it------------
			pop esi
			push esi
			;--------------mul 2,1-----------------------
			sub esi,4
			mov eax,2
			imul dword ptr [esi]
			add val,eax
			;--------------mul 2,3-----------------------
			add esi,8
			mov eax,-2
			imul dword ptr [esi]
			add val,eax
			jmp forall
			;-----------first row-----------------
		frow:
				
			
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			;-------first element------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			cmp eax,dword ptr 0
			je fer
			
			;---------multiplication 1,3 element------------
			add esi,4
			mov eax,-1
			mul dword ptr[esi]
			add val,eax
			;---------------------------------------------
			;---------return original index and save it------------
			pop esi
			push esi
			;--------------mul 2,3-----------------------
			add esi,4
			mov eax,-2
			imul dword ptr [esi]
			add val,eax
				;------------------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,imgsize
			sub edi,height
			inc edi
			cmp edi,eax
			je forall
			fer:
				;---------return original index and save it------------
				pop esi
				push esi
				;------set esi on index-------------
				mov eax,height
				mov cur,4
				mul cur
				add esi,eax
				sub esi,4
				
				;-------------multiplication 3,3 element----------
				add esi ,8
				mov edi,dword ptr [esi]
				add val,edi
			jmp forall
		;--------------last row-----------------------
		lrow:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			sub esi,4
			;-------last element------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,height
			dec edi
			cmp eax,edi
			je ler
			;---------multiplication 1,1 element--------------
			mov eax,1
			mul dword ptr [esi]
			add val,eax
			
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,imgsize
			dec edi
			cmp edi,eax
			je forall
			ler:
				;---------return original index and save it------------
				pop esi
				push esi
				;------set esi on index-------------
				mov eax,height
				mov cur,4
				mul cur
				add esi,eax
				sub esi,4
				;-------------multiplication 3,1 element--------
				mov edi,dword ptr [esi]
				add val,edi
					;---------return original index and save it------------
				pop esi
				push esi
				;--------------mul 2,1-----------------------
				sub esi,4
				mov eax,2
				imul dword ptr [esi]
				add val,eax
				

			


			
		
		
		
		
		
		
		
		
		
		forall:
		
			;-----------set vaLue in green-----------------
			mov esi, greenChannel
			mov eax,index
			add esi,eax
			mov eax,val
			
			mov [esi],eax
			
			;-------return to original--------
			pop esi
			pop ecx
			
			add esi,4
			add index,4
			dec ecx
			cmp ecx,0
			
			je next
	jmp updatey
	


	
	
	
	
	
	
		
	updatex :
		mov val ,0
		;--------save values-----------------
		push ecx
		push esi
	
		;-------corner cases--------------
		;-------------first row----------------
		
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
			
		mov edi, height
		mov edx,0
		div edi
		
		cmp edx,0
		je frowy
		
		
		;--------------last row-----------
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
		
		mov edi, height
		mov edx,0
		div edi
		dec edi
		cmp edx,edi
		je lrowy


		;------first col-----------------
		mov eax,index
		mov cur,4
		mov edx,0
		div cur
		
		cmp eax,height
		
		jb fcoly
		
		;------last col-----------
		mov edi,imgsize
		sub edi,height

		cmp eax,edi
		ja lcoly

		
		
		
		
		
		
		
		
		;------set esi on index-------------
		mov eax,height
		mov cur,4
		imul cur
		sub esi,eax
		sub esi,4
		;---------imultiplication 1,1 element--------------
		mov eax,-1
		imul dword ptr [esi]
		add val,eax
		;---------imultiplication 1,2 element---------
		add esi,4
		mov eax,-2
		imul dword ptr [esi]
		add val,eax
		;---------multiplication 1,3 element------------
		add esi,4
		mov eax,-1
		mul dword ptr[esi]
		add val,eax
		;---------return original index and save it------------
		pop esi
		push esi
		;------set esi on index-------------
		mov eax,height
		mov cur,4
		mul cur
		add esi,eax
		sub esi,4
		;-------------multiplication 3,1 element--------
		mov edi,dword ptr [esi]
		add val,edi
		;------------multiplication 3,2 element----------
		add esi ,4
		mov eax,2
		mul dword ptr [esi]
		add val,eax
		;-------------multiplication 3,3 element----------
		add esi ,4
		mov edi,dword ptr [esi]
		add val,edi
		jmp forally
		
		


		;-------first column-----------
		fcoly:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			add esi,eax
			sub esi,4
			
			;-------------multiplication 3,1 element--------
			mov edi,dword ptr [esi]
			add val,edi
			
			;------------multiplication 3,2 element----------
			add esi ,4
			mov eax,2
			mul dword ptr [esi]
			add val,eax
		
			;-------------multiplication 3,3 element----------
			add esi ,4
			mov edi,dword ptr [esi]
			add val,edi
				
			jmp forally
			;------------------last col----------------
		lcoly:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			sub esi,4
			;---------multiplication 1,1 element--------------
			mov eax,-1
			mul dword ptr [esi]
			add val,eax
			;---------multiplication 1,2 element---------
			add esi,4
			mov eax,-2
			mul dword ptr [esi]
			add val,eax
			;---------multiplication 1,3 element------------
			add esi,4
			mov eax,-1
			mul dword ptr[esi]
			add val,eax
			jmp forally
			;-----------first row-----------------
		frowy:
				
			
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			;-------first element------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			cmp eax,dword ptr 0
			je fery
			;---------multiplication 1,2 element---------
			mov eax,-2
			mul dword ptr [esi]
			add val,eax
			;---------multiplication 1,3 element------------
			add esi,4
			mov eax,-1
			mul dword ptr[esi]
			add val,eax
			;------------------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,imgsize
			sub edi,height
			inc edi
			cmp edi,eax
			je forally
			fery:
				;---------return original index and save it------------
				pop esi
				push esi
				;------set esi on index-------------
				mov eax,height
				mov cur,4
				mul cur
				add esi,eax
				sub esi,4
				;------------multiplication 3,2 element----------
				add esi ,4
				mov eax,2
				mul dword ptr [esi]
				add val,eax
				;-------------multiplication 3,3 element----------
				add esi ,4
				mov edi,dword ptr [esi]
				add val,edi
			jmp forally
		;--------------last row-----------------------
		lrowy:
			;------set esi on index-------------
			mov eax,height
			mov cur,4
			mul cur
			sub esi,eax
			sub esi,4
			;-------last element------------------
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,height
			dec edi
			cmp eax,edi
			je lery
			;---------multiplication 1,1 element--------------
			mov eax,-1
			mul dword ptr [esi]
			add val,eax
			;---------multiplication 1,2 element---------
			add esi,4
			mov eax,-2
			mul dword ptr [esi]
			add val,eax
			mov eax,index
			mov cur,4
			mov edx,0
			div cur
			mov edi,imgsize
			dec edi
			cmp edi,eax
			je forally
			lery:
				;---------return original index and save it------------
				pop esi
				push esi
				;------set esi on index-------------
				mov eax,height
				mov cur,4
				mul cur
				add esi,eax
				sub esi,4
				;-------------multiplication 3,1 element--------
				mov edi,dword ptr [esi]
				add val,edi
				;------------multiplication 3,2 element----------
				add esi ,4
				mov eax,2
				mul dword ptr [esi]
				add val,eax

			


			
		
		
		
		
		
		
		
		
		
		forally:
		
			;-----------set vaLue in green-----------------
			mov esi, greenChannel
			mov eax,index
			add esi,eax
			mov eax,val
			
			mov [esi],eax
			
			;-------return to original--------
			pop esi
			pop ecx
			
			add esi,4
			add index,4
			dec ecx
			cmp ecx,0
			
			je next
	jmp updatex

	next:

	popad
	ret
sobel endp 
;////////////////////////////////////

histo proc channel:ptr dword,imageSize:  DWORD
pushad

  mov ecx,256
  mov esi,offset grayLevel
  mov edi,offset newgrayLevel
Zero:
  mov [esi],dword ptr 0
  mov [edi],dword ptr 0
  add edi,4
  add esi,4
loop Zero

  mov ecx,imageSize
  mov esi, channel
ComputePMF:
	
	mov eax,dword ptr [esi]
	push esi
	mov esi,offset grayLevel
	add eax,eax
	add eax,eax
	add esi,eax
	mov eax,[esi]
	
     add eax,1
	mov[esi],eax
	
	
	pop esi
	add esi,4
	
loop ComputePMF
mov ecx,255
mov edi,offset grayLevel
mov eax,[edi]
add edi,4
ComputeCMF:
	add eax,[edi]
	
	mov [edi],eax
     add edi,4
loop ComputeCMF
mov ecx,imageSize
mov esi, channel
updateChannel:
    mov edi,offset grayLevel
    mov eax,dword ptr[esi]
    
    add eax,eax
    add eax,eax
    add edi,eax
    mov eax,[edi]

    mov [esi],eax
    
    add esi,4

loop updateChannel



popad
ret
histo endp





; DllMain is required for any DLL
DllMain PROC hInstance:DWORD, fdwReason:DWORD, lpReserved:DWORD
mov eax, 1 ; Return true to caller.
ret
DllMain ENDP
END DllMain