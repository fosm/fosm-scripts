tgj3	; Fix up references to non-existant nodes from ways
	;
	; Iterate through all ways
	; Check each node
	s count=0
	s w=^tgjCheckpoint
	f  d  i w="" q
	. s w=$o(^way(w)) i w="" q
	. s s=""
	. f  d  i s="" q
	. . s s=$o(^way(w,s)) i s="" q
	. . s count=count+1
	. . i count#10000=0 w "." s ^tgjCheckpoint=w
	. . s n=^way(w,s)
	. . s version=$o(^nodeVersion(n,"v",""),-1)
	. . i version="" s ^tgjBad(w,s)="No versions of node exist" q
	. . s changeset=^nodeVersion(n,"v",version)
	. . s visible=$p(^c(changeset,"n",n,"v",version,"a"),$c(1),5)
	. . i visible="false" s ^tgjBad(w,s)="Node exists but has been deleted" q
	. . i '$d(^wayByNode(n,w)) s ^tgjBadx(w,s)="No entry for node in ^wayByNode"
	q














fix	; Find all the nodes
	; If the node has been deleted (latest version has visible=false) then reinstate it
	; If the node does not exist at all then report No Versions
	s count=0
	s w=""
	f  d  i w="" q
	. s w=$o(^tgjBad(w)) i w="" q
	. s seq=""
	. f  d  i seq="" q
	. . s seq=$o(^tgjBad(w,seq)) i seq="" q
	. . ;i $e(^tgjBad(w,seq),1,7)="Deleted" q
	. . ;i $e(^tgjBad(w,seq),1,11)="no versions" q
	. . i $g(^way(w,seq))'=^tgjBad(w,seq) s ^tgjCheck(w,seq)=1 q
	. . s n=^way(w,seq)
	. . s version=$o(^nodeVersion(n,"v",""),-1) i version="" w !,w," ",seq,"=",n," no versions" q
	. . s changeset=^nodeVersion(n,"v",version)
	. . s visible=$p(^c(changeset,"n",n,"v",version,"a"),$c(1),5)
	. . i visible="" w !,w," ",seq,"=",n," not deleted" q  ; Node not deleted
	. . w !,w," ",seq,"=",n," deleted, needs to be undeleted"
	. . s $p(^c(changeset,"n",n,"v",version,"a"),$c(1),5)=""
	. . s count=count+1
	w !,count
	q











