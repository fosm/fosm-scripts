ENIGMA	; Generate Code Wheels so that we can start encoding Messages ;12Aug2015/RWF ;19JUN2015@1410/12JUN2015/RCRV	

; Version 2
	QUIT
	;  ====================
GEN4	; Generate 4 wheels - Nazi Naval Enhancement
	;  ====================
GEN3	; Generate 3 wheels - General Nazi Use, Army and Air Force
	;  ====================
	; V  -  The range of Values to use to randomize the letters in the wheels
	;         128+(100k-1) 
	; WSET is the set of wheels to use
ENCODE(MSG,WSET)	; Encode a message
	N C,I,OUT,O
	K WHEEL,ENIG
	D LOAD(WSET) ;Fill RESET with the wheels to use.
	M WHEEL=RESET
	S OUT=""
	M ENIG("W")=RESET
	F I=1:1:$L(MSG) S C=$E(MSG,I)  D
	. S J=0
	. ;  Save the character after the adjustment, then increment the wheel(s)
	. F  S J=$O(WHEEL(J))  Q:J=""  S D=C,O=$A(C)-31,C=$E(WHEEL(J),O),ENIG(I,J,"E",D)=O_"="_C
	. S OUT=OUT_C
	. D INC(.WHEEL)
	.QUIT
	QUIT OUT
	; ====================
DECODE(MSG,WSET)	; Decode a message
	N C,CODED,I,OUT
	K WHEEL
	D LOAD(WSET) ;Fill RESET with the wheels to use.
	M WHEEL=RESET
	S OUT=""
	F I=1:1:$L(MSG) S C=$E(MSG,I) D
	. S J=9999 ;Go backward thru wheels
	. F  S J=$O(WHEEL(J),-1)  Q:J=""  D
	. . S D=C
	. . S K=$F(WHEEL(J),C)-1,C=$C(K+31)
	. . S ENIG(I,J,"D",D)=C
	. .QUIT
	. S OUT=OUT_C
	. D INC(.WHEEL)
	.QUIT
	QUIT OUT
	;  ====================
	;  Incriment the wheels one click as a cascade to each rotar.
	
INC(VALUE)	;  Between characters, This makes the code different for each character.
	N L,X
	S L=$L(VALUE(1))
	S VALUE(1,"CNT")=$G(VALUE(1,"CNT"))+1
	S VALUE(1)=$E(VALUE(1),2,L)_$E(VALUE(1),1)
	I VALUE(1,"CNT")>L D
	. S VALUE(1,"CNT")=0
	. S VALUE(2,"CNT")=$G(VALUE(2,"CNT"))+1
	. S VALUE(2)=$E(VALUE(2),2,L)_$E(VALUE(2),1)
	. I VALUE(2,"CNT")>L D
	. . S VALUE(2,"CNT")=0
	. . S VALUE(3,"CNT")=$G(VALUE(3,"CNT"))+1
	. . S VALUE(3)=$E(VALUE(3),2,L)_$E(VALUE(3),1)
	. . I VALUE(3,"CNT")>L D
	. . . S VALUE(3,"CNT")=0
	. . . Q:'$D(VALUE(4))
	. . . ;
	. . . S VALUE(4,"CNT")=$G(VALUE(4,"CNT"))+1
	. . . S VALUE(4)=$E(VALUE(4),2,L)_$E(VALUE(4),1)
	. . . I VALUE(4,"CNT")>L S VALUE(4,"CNT")=0
	. . .QUIT
	. .QUIT
	.QUIT
	QUIT
	; ====================
	;  vvvvvvvvvvvvvvvvvvvv
LOAD(WS)	;Load a set of wheels that have been built.
	;A comma list of wheels to use. Should be 3 or 4 numbers, but more or less and be accommodated.
	N I,J
	K RESET
	I $L(WS)=0 W !,"Empty set of wheels!" Q
	;
	S I=1
	F I=1:1 S J=$P(WS,",",I) Q:J=""   S RESET(I)=^ENIGMA(J)
	QUIT
	;  ====================
	;  vvvvvvvvvvvvvvvvvvvv
	; K - The number of Wheels to generate
BUILD(K)	;Build wheels and store  
	;Seems like a good number
	S K=$G(K,10)  ;  Default to 10
	F I=1:1:K   S ^ENIGMA(I)=$$GENERATE()
	W !,I," Wheels built.",!
	QUIT
	;  ====================
	; V  -  The range of Values to use to randomize the letters in the wheels
	;         128+(100k-1) 
GENERATE(V)	; Take the random input and then randomize the character set
	S:'$D(V) V=$R(100000)+128
	N A,J,K,T
	S J=32
	F  S T=$R(V) S:'$D(A(T)) A(T)=$C(J),J=J+1 Q:J>126
	S (J,K)=""
	F  S J=$O(A(J))  Q:J=""  S K=K_A(J)
	QUIT K
	;  ====================
