write	; Output methods
	;
w(string)	;
w1	;
	s $et="g error^write"
	w string
	q
error	;
	;
	i $p($zstatus,",",3)="%SYSTEM-E-ENO11" h 1 s $ecode="" g w1
	q
