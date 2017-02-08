pipe	; Test output to named pipe
	zsystem "mkfifo output.pipe; cat <output.pipe >output.txt &"
	s pipe="output.pipe"
	o pipe:(nowrap:stream:fifo)
	u pipe
	f i=1:1 w $r(1000000)
	w "z"
	c pipe
	q
