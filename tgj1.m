tgj1	; way analysis
	q

ways	;
	s f="/home/80n/ways.osm"
	o f:READ
	s g="/home/80n/analysis1.txt"
	o g:NEW
	s way=0
	
	f i=1:1  d
	. u f r line
	. u g
	. i line["<way" d
	. . i way'=0 w i," ",way," unexpected <way ",line,!
	. . s way=1
	. ;i line["<</way>>" d  q
	. ;. i way'=1 w i," ",way," unexpected <</way>> ",line,!
	. ;. s way=2
	. i line["</way>" d
	. . i way'=1 w i," ",way," unexpected </way> ",line,!
	. . s way=0
	. i i#10000000=0 w i," checkpoint ",line,!
	c f
	q

	
pipe	;
	s directory="/home/80n/"
	s pipe=directory_"earth.pipe"
	s iDateTime="dateTime"
	s earthFile=directory_"earth-"_iDateTime_".temp"
	zsystem "rm "_pipe_"; mkfifo "_pipe_"; cat <"_pipe_" >"_earthFile_" &"
	;
	o pipe:(nowrap:stream:fifo)
	;
	; Let's do it
	u pipe
	;
	f i=1:1:500000000 s xml=$j(i,10)_"<tag key='value'/>"_$c(13,10) w xml
	c pipe
	;
	;
