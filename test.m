test	;
	s bsize=250
	k ^osmTemp($j)
	h 5
	s start=$h
	s nodeCount=0,uniqueNode=0
	s wayCount=0,uniqueWay=0
	s qsItemCount=0
	s bllat=49.9212162
	s bllon=-0.8289528
	s trlat=50.9421508
	s trlon=1.7959080
	s qsRoot=$$bbox^quadString(bllat,bllon,trlat,trlon)
	w !,qsRoot
	s oBox("bllat")=bllat
	s oBox("bllon")=bllon
	s oBox("trlat")=trlat
	s oBox("trlon")=trlon
	s oBox("root")=""
	s ok=$$map(.oBox)
	s end=$h
	w !,"Elapsed = ",$p(end,",",2)-$p(start,",",2)
	w !,"Node count = ",nodeCount,?30,uniqueNode
	w !,"Way count = ",wayCount,?30,uniqueWay
	w !,"qsItem count = ",qsItemCount
	q


map(oBox)       ; Private ; Process a map request
        ;
        n qsItem,continue
        ;
        s continue=1
        ;
        s qsItem=oBox("root")
        ;
        f  d  i qsItem="" q
        . s qsItem=$$nextNode(.oBox,qsItem,"*","*") i qsItem="" q
        . s continue=$$mapNode(qsItem,.oBox) i 'continue s qsItem="" q
        ;
        i 'continue q 0
        q 1


mapNode(qsItem,bbox)       ; Process a single quadtree
        ;
        n nodeId,wayId,continue
        ;
        s continue=1
        ;
        s nodeId=""
        f  d  i nodeId="" q
        . s nodeId=$o(^e(qsItem,"n",nodeId)) i nodeId="" q
        . ;
        . ; Check that node is actually within bounding box
        . i '$$nodeInBox^xapi(qsItem,nodeId,.bbox) q
        . s continue=$$node(nodeId,"*","*",.bbox,1) i 'continue s nodeId="" q
        . ;
        . s wayId=""
        . f  d  i wayId="" q
        . . s wayId=$o(^wayByNode(nodeId,wayId)) I wayId="" q
        . . s continue=$$way(wayId,"*","*",.bbox,1) i 'continue s wayId="" q
        . i 'continue s nodeId="" q
        ;
        i 'continue q 0
        q 1

node(nodeId,k,v,bbox,x) ;
	;w !,"Got node ",nodeId
	;w "."
	s chapterId=nodeId\bsize
	s verseId=nodeId#bsize+1
	s bits=$g(^osmTemp($j,"node",chapterId),$zbitstr(bsize,0))
	;i '$zbitget(bits,verseId) s ^osmTemp($j,"node",chapterId)=$zbitset(bits,verseId,1) s uniqueNode=uniqueNode+1
	;i '$d(^osmTemp($j,"node",nodeId)) s ^osmTemp($j,"node",nodeId)="" s uniqueNode=uniqueNode+1
	s nodeCount=nodeCount+1
	q 1
	
way(wayId,k,v,bbox,x)	;
	;w !,"Got way ",wayId
	s chapterId=wayId\bsize
	s verseId=wayId#bsize+1
	s bits=$g(^osmTemp($j,"way",chapterId),$zbitstr(bsize,0))
	;i '$zbitget(bits,verseId) s ^osmTemp($j,"way",chapterId)=$zbitset(bits,verseId,1) s uniqueWay=uniqueWay+1
	;i '$d(^osmTemp($j,"way",wayId)) s ^osmTemp($j,"way",wayId)="" s uniqueWay=uniqueWay+1
	s wayCount=wayCount+1
	q 1

nextNode(oBox,qsItem,k,v)       ; Private ; get the next tile containing a node of the right kind within the bounding box
        ;
        n i,done,qsLast
        ;
        s done=0
        f  d  i done q
        . i k="*",v="*" s qsItem=$o(^e(qsItem))
        . e  s qsItem=$o(^nodex(k,v,qsItem))
        . i qsItem="" s done=1 q
        . ;
		. ;w !,qsItem
		. s qsItemCount=qsItemCount+1
        . ; If we are not still inside the bbox root area then we are done
        . i $e(qsItem,1,$l(oBox("root")))'=oBox("root") s qsItem="",done=1 q
        . ;
        . ; If we are still inside the bbox area then we have the next tile
        . i $$bboxInQs^quadString(.oBox,qsItem) s done=1 q
        . ;
        . ; Split off the last quad
        . s qsLast=$e(qsItem,$l(qsItem)),qsItem=$e(qsItem,1,$l(qsItem)-1)
        . ;
        . ; Iterate through the remaining tiles at this level
        . i "a"[qsLast,$$bboxInQs^quadString(.oBox,qsItem_"b") s qsItem=qsItem_"b",done=1 q
        . i "ab"[qsLast,$$bboxInQs^quadString(.oBox,qsItem_"c") s qsItem=qsItem_"c",done=1 q
        . i "abc"[qsLast,$$bboxInQs^quadString(.oBox,qsItem_"d") s qsItem=qsItem_"d",done=1 q
        . ;
        . ; Walk down the tree until we find a tile that is not in the bbox area
        . ; This potentially skips large parts of the tree that are outside the box
        . f i=1:1:$l(qsItem) i '$$bboxInQs^quadString(.oBox,$e(qsItem,1,i)) q
        . ;
        . ; Increment to the next tile, then rinse and repeat
        . s qsItem=$$incrementQs^quadString($e(qsItem,1,i)) i qsItem="" s done=1 q
        ;
        q qsItem
