all:
	gcc -c xapi.c -I${gtm_dist}
	gcc xapi.o -o xapi -L ${gtm_dist} -Wl,-rpath=${gtm_dist} -lgtmshr
	gcc -c xapid.c -I${gtm_dist}
	gcc xapid.o -o xapid -L ${gtm_dist} -Wl,-rpath=${gtm_dist} -lgtmshr

