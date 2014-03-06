"Hosted at https://github.com/q335r49/textabyss

if &compatible|se nocompatible|en      "[Do not change] Enable vim features, sets ttymouse

"Plane settings
	nn <silent> <f10> :if exists('t:txb')\|call TXBdoCmd('ini')\|else\|call <SID>initPlane()\|en<cr>
	                                   "Hotkey to load plane and activate keyboard commands
	let s:hkName='<f10>'               "The name of the above key (used for help files)
	let s:panL=15                      "Lines panned with jk
	let [s:aniStepH,s:aniStepV]=[9,2]  "Keyboard pan animation step horizontal / vertical (higher pans faster)
	let s:mouseAcc=[0,1,2,4,7,10,15,21,24,27]       "for every N steps mouse moves, pan mouseAcc[N] steps
"Map settings
	let s:mapL=45                      "Map grid corresponds to 1 split x s:mapL lines
	let [s:mBlockH,s:mBlockW]=[2,5]    "Map grid displayed as s:mBlockH lines x s:mBlockW columns
	hi! link TXBmapSel Visual          "Highlight color for map cursor on label
	hi! link TXBmapSelEmpty Search     "Highlight color for map cursor on empty grid
"Optional components -- uncomment to activate
	"let s:option_remap_G_gg           "G and gg goes to the next / prev nonblank line followed by 6 blank lines (counts still work normally)

"Reasons for changing internal settings:
	se noequalalways                  "[Do not change] Needed for correct panning
	se winwidth=1                     "[Do not change] Needed for correct panning
	se winminwidth=0                  "[Do not change] Needed For correct panning
	se viminfo+=!                     "Needed to save map and plane in between sessions
	se sidescroll=1                   "Smoother panning
	se nostartofline                  "Keeps cursor in the same position when panning
	se mouse=a                        "Enables mouse
	se lazyredraw                     "Less redraws
	se virtualedit=all                "Makes leftmost split aligns correctly
	se hidden                         "Suppresses error messages when a modified buffer panns offscreen

if exists('s:option_remap_G_gg') && s:option_remap_G_gg==1
	fun! <SID>G(count)
		let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')+1,1)+search('\S\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n','W')? line('.') : line('$')]
		return (mode=='no'? "\<esc>0".v:operator : mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '$' : '')
	endfun
	fun! <SID>gg(count)
		let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')-1,1)+search('\S\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n','Wb')? line('.') : 1]
		return (mode=='no'? "\<esc>$".v:operator :  mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '0' : '')
	endfun
	no <expr> G <SID>G(v:count)        "G goes to the next nonblank line followed by 6 blank lines (counts still work normally)
	no <expr> gg <SID>gg(v:count)      "gg goes to the previous nonblank line followed by 6 blank lines (counts still work normally)
	unlet s:option_remap_G_gg
endif

augroup TXB
	au!
	if v:version > 703 || v:version==703 && has("patch748")
		au VimResized * call <SID>centerCursor(screenrow(),screencol())
	else
		au VimResized * call <SID>centerCursor(winline(),eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()'))
	en
augroup END
fun! <SID>centerCursor(row,col)
	if !exists('t:txb') | return | en
	let restoreView='norm! '.virtcol('.').'|'
	call TXBload()
	call s:nav(a:col/2-&columns/4)
	let dy=&lines/4-a:row/2
	exe dy>0? restoreView.dy."\<c-y>" : dy<0? restoreView.(-dy)."\<c-e>" : restoreView
endfun

nn <silent> <leftmouse> :exe get(TXBmsCmd,&ttymouse,TXBmsCmd.default)()<cr>
let TXBmsCmd={}
let TXBkyCmd={}
fun! s:printHelp()
	let helpmsg="\n\n\n\\CWelcome to Textabyss v1.6!
	\\n\\Cgithub.com/q335r49/textabyss
	\\n\nPress ".s:hkName." to start. You will be prompted for a file pattern. You can try \"*\" for all files or, say, \"pl*\" for \"pl1\", \"plb\", \"planetary.txt\", etc.. You can also start with a single file and use ".s:hkName."A to append additional splits.\n
	\\nOnce loaded, use the mouse to pan or press ".s:hkName." followed by:
	\\n    h j k l     Pan left / down / up / right*
	\\n    y u b n     Pan upleft / downleft / upright / downright*
	\\n    o           Open map (map grid: 1 split x ".s:mapL." lines)
	\\n    r           Redraw
	\\n    .           Snap to map grid
	\\n    D A E       Delete split / Append split / Edit split settings
	\\n    <f1>        Show this message
	\\n    q <esc>     Abort
	\\n    ^X          Delete hidden buffers
	\\n* The movement keys take counts, as in vim. Eg, 3j will move down 3 grids. The count is capped at 99. Each grid is 1 split x 15 lines.
	\\n\n\\CTroubleshooting
	\\n\nMOUSE\nIf dragging the mouse doesn't pan, try ':set ttymouse=sgr' or ':set ttymouse=xterm2'. Most other modes should work but the panning speed multiplier will be disabled. 'xterm' does not report dragging and will disable mouse panning entirely.
	\\n\nDIRECTORIES\nEnsuring a consistent starting directory is important because relative names are remembered (use ':cd ~/PlaneDir' to switch to that directory beforehand). Ie, a file from the current directory will be remembered as the name only and not the path. Adding files not in the current directory is ok as long as the starting directory is consistent.\n
	\\nSCROLLBIND DESYNC\nRegarding scrollbinding splits of uneven lengths -- I've tried to smooth this over but occasionally splits will still desync. You can press r to redraw when this happens. Actually, padding about 500 or 1000 blank lines to the end of every split would solve this problem with very little overhead. You might then want to remap G (go to end of file) to go to the last non-blank line rather than the very last line.
	\\n\nHORIZONTAL SPLITS\nHorizontal splits aren't supported and may interfere with panning.\n
	\\n\\CAdvanced\n
	\\n--- Saving Planes ---\n
	\\nThe script uses the viminfo file (:help viminfo) to save plane and map data. The option to save global variables in CAPS is set automatically when the script is loaded. The saved plane is suggested when you press ".s:hkName.".\n
	\\nTo manually save a snapshot of the current plane, navigate to the tab containing the plane and try:
	\\n    :let BACK01=deepcopy(t:txb) \"make sure name is in all CAPS\n
	\\nYou can then restore via either:
	\\n    :call TXBload(BACK01)       \"load in a new tab, or ...
	\\n    :let g:TXB=BACK01           \"overwrite saved plane and load on ".s:hkName."\n
	\\nAlternatively, you can save a snapshot of the viminfo via:
	\\n    :wviminfo viminfo-backup-01\n
	\\nYou can then restore it by quitting vim and replacing your current viminfo file with the backup.\n
	\\n--- Line Anchors ---\n
	\\n    ^L          Insert line anchor
	\\n    ^A          Align all text anchors in split
	\\nInserting text at the top of a split misaligns everything below. Line anchors try to address this problem. A line anchor is simply a line of the form `txb:current line`, eg, `txb:455`. It can be inserted with ".s:hkName." ^L. The align command ".s:hkName." ^A attempts to restore all displaced anchors in a split by removing or inserting immediately preceding blank lines. If there aren't enough blank lines to remove the effort will be abandoned with an error message.
	\\n\n\\CRecent Changes\n
	\\n1.6.5     Lots of initialization fixes
	\\n1.6.4     Center and redraw on zoom
	\\n1.6.2     Line anchors
	\\n1.6.1     Movement commands (map and plane) now take counts
	\\n1.6.0     Map positioning syntax added
	\\n1.5.8     s:pager function to avoid bug in vim's pager
	\\n1.5.7     Eliminate random cursor jitter during panning"
	let width=&columns>80? min([&columns-10,80]) : &columns-2
	call s:pager(s:formatPar(helpmsg,width,(&columns-width)/2))
endfun

fun! TXBdeleteCol(index)
	call remove(t:txb.name,a:index)	
	call remove(t:txb.size,a:index)	
	call remove(t:txb.exe,a:index)	
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
endfun

fun! <SID>initPlane(...)                                          
	let filtered=[]
	if !a:0
		let [more,&more]=[&more,0]
		if &ttymouse==?"xterm"
			echom "WARNING: ttymouse is set to 'xterm', which doesn't report mouse dragging."
			echom "    Try ':set ttymouse=xterm2' or ':set ttymouse=sgr'"
		elseif &ttymouse!=?"xterm2" && &ttymouse!=?"sgr"
			echom "WARNING: For better mouse panning performance, try ':set ttymouse=xterm2' or 'set ttymouse=sgr'."
			echom "    Your current setting is: ".&ttymouse
		en
		if v:version < 703 || v:version==703 && !has('patch30')
			echom "WARNING: Your Vim version < 7.3.30, which means that the plane and map cannot be saved between sessions."
			echom "    Consider upgrading Vim or manually saving and loading the g:TXB variable as a string."
		en
       	if exists('g:TXB') && type(g:TXB)==4
			let plane=deepcopy(g:TXB)
			for i in range(plane.len-1,0,-1)
				if !filereadable(plane.name[i])
					call add(filtered,remove(plane.name,i))
					call remove(plane.size,i)	
					call remove(plane.exe,i)	
				en
			endfor
			if !empty(filtered)
				let plane.len=len(plane.name)
				let [plane.ix,j]=[{},0]
				for e in plane.name
					let [plane.ix[e],j]=[j,j+1]
				endfor
				let msg="\n   ".join(filtered," (unreadable)\n   ")." (unreadable)\n ---- ".len(filtered)." unreadable file(s) ----"
            	let msg.="\nWARNING: Unreadable file(s) will be removed from the plane; make sure you are in the right directory!"
				let msg.="\nRestore map and plane and remove unreadable files?\n -> Type R to confirm / ESC / F1 for help: "
			else
				let msg="\nRestore last session (map and plane)?\n -> Type ENTER / ESC / F1 for help:"
			en
		elseif exists('TXB_PREVPAT')
        	let plane=s:makePlane(g:TXB_PREVPAT)
			let msg="\nUse last used pattern '".g:TXB_PREVPAT."'?\n -> Type ENTER / ESC / F1 for help:"
		else
			let plane={'name':''}
		en
	else
		let plane=s:makePlane(a:1)
		if a:0 && exists('g:TXB') && type(g:TXB)==4
			let msg ="\nWARNING: The last plane and map you used will be OVERWRITTEN. Press F1 for options on saving the old plane\n -> Type O to confirm overwrite / ESC / F1 for help:"
		else
			let msg="\nUse current pattern '".a:1."'?\n -> Type ENTER / ESC / F1 for help:"
		en
	en

	if !empty(plane.name) || !empty(filtered)
		let curbufix=index(plane.name,expand('%'))
		if curbufix==-1
			ec "\n  " join(plane.name,"\n   ") "\n ---- " plane.len "file(s) ----" msg
		else
			let displist=copy(plane.name)
			let displist[curbufix].=' (current file)'
			ec "\n  " join(displist,"\n   ") "\n ----" plane.len "file(s) (Plane will be loaded in current tab) ----" msg
		en
		let c=getchar()
	elseif a:0
		ec "\n    (No matches found)"
		let c=0
	else
		let c=0
	en

	if a:0 && exists('g:TXB') && type(g:TXB)==4
		if c==79
			if curbufix==-1 | tabe | en
			let g:TXB=plane
			if a:0
				let g:TXB_PREVPAT=a:1
			en
			call TXBload(plane)
		elseif c is "\<f1>"
			call s:printHelp() 
		else
			let input=input("> Enter file pattern or type HELP: ")
			if input==?'help'
				call s:printHelp()
			elseif !empty(input)
				call <SID>initPlane(input)
			en
		en
	elseif !empty(filtered)
		if c==82
			if curbufix==-1 | tabe | en
			let g:TXB=plane
			if a:0
				let g:TXB_PREVPAT=a:1
			en
			call TXBload(plane)
		elseif c is "\<f1>"
			call s:printHelp() 
		else
			let input=input("> Enter file pattern or type HELP: ")
			if input==?'help'
				call s:printHelp()
			elseif !empty(input)
				call <SID>initPlane(input)
			en
		en
    elseif c==13 || c==10
		if curbufix==-1 | tabe | en
		let g:TXB=plane
		if a:0
			let g:TXB_PREVPAT=a:1
		en
		call TXBload(plane)
	elseif c is "\<f1>"
		call s:printHelp() 
	else
		let input=input("> Enter file pattern or type HELP: ")
		if input==?'help'
			call s:printHelp()
		elseif !empty(input)
			call <SID>initPlane(input)
		en
	en
	if exists('more')
		let &more=more
	en
endfun

fun! s:makePlane(name,...)
	let plane={}
	let plane.name=type(a:name)==1? map(filter(split(glob(a:name),"\n"),'filereadable(v:val)'),'escape(v:val," ")') : type(a:name)==3? a:name : 'INV'
	if plane.name is 'INV'
     	throw 'First argument ('.string(a:name).') must be string (filepattern) or list (list of files)'
	else
		let plane.len=len(plane.name)
		let plane.size=exists("a:1")? a:1 : repeat([60],plane.len)
		let plane.exe=exists("a:2")? a:2 : repeat(['se scb cole=2 nowrap'],plane.len)
		let [plane.ix,i]=[{},0]
		let plane.map=[[]]
		for e in plane.name
			let [plane.ix[e],i]=[i,i+1]
		endfor
		let plane.gridnames=s:getGridNames(plane.len+50)
		return plane
	en
endfun

let TXBkyCmd["\<c-l>"]=":call setline('.','txb:'.line('.'))\<cr>"
let TXBkyCmd["\<c-a>"]=":call TXBanchor(1)\<cr>"
fun! TXBanchor(interactive)
	let restoreView='norm! '.line('w0').'zt'.line('.').'j'.virtcol('.').'|'
	let line=search('^txb:','W')
	1
	if a:interactive
	   	let [cul,&cul]=[&cul,1]
		while line
			redr
			let mark=getline('.')[4:]
			if mark<line && mark>0
				let insertions=line-mark
				if prevnonblank(line-1)>=mark
	  				let &cul=cul
					throw "Not enough blank lines to restore current marker!"
				elseif input('Remove '.insertions.' blank lines here (y/n)?','y')==?'y'
					exe 'norm! kd'.(insertions==1? 'd' : (insertions-1).'k')
				en
			elseif mark>line && input('Insert '.(mark-line).' line here (y/n)?','y')==?'y'
				exe 'norm! '.(mark-line)."O\ej"
			en
			let line=search('^txb:','W')
		endwhile
	  	let &cul=cul
	else
		while line
			let mark=getline('.')[4:]
			if mark<line && mark>=0
				let insertions=line-mark
				if prevnonblank(line-1)>=mark
					throw "Not enough blank lines to restore current marker!"
				else
					exe 'norm! kd'.(insertions==1? 'd' : (insertions-1).'k')
				en
			elseif mark>line
				exe 'norm! '.(mark-line)."O\ej"
			en
			let line=search('^txb:','W')
		endwhile
	en
	exe restoreView
	echon "\rRealign complete: " expand('%')
endfun

let s:glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
fun! s:initDragDefault()
	if exists('t:txb')
		call s:saveCursPos()
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:updateCursPos()
			let s0=get(t:txb.ix,bufname(winbufnr(v:mouse_win)),-1)
			let t_r=v:mouse_lnum/s:mapL
			echon t:txb.gridnames[s0].t_r.get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
			return "keepj norm! \<leftmouse>"
		else
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:mapL
			let ecstr=t:txb.gridnames[s0].t_r.get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
			while c!="\<leftrelease>"
				if v:mouse_win!=w0
					let w0=v:mouse_win
					exe "norm! \<leftmouse>"
					if !exists('t:txb')
						return ''
					en
					let [b0,wrap]=[winbufnr(0),&wrap]
					let [x,y,offset,ix]=wrap? [wincol(),line('w0')+winline(),0,get(t:txb.ix,bufname(b0),-1)] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol(),get(t:txb.ix,bufname(b0),-1)]
				else
					if wrap
						exe "norm! \<leftmouse>"
						let [nx,l0]=[wincol(),y-winline()]
					else
						let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
					en
					let [x,xs]=x && nx? [x,s:nav(x-nx)] : [x? x : nx,0]
					exe 'norm! '.bufwinnr(b0)."\<c-w>w".(l0>0? l0 : 1).'zt'
					let [x,y]=[wrap? v:mouse_win>1? x : nx+xs : x, l0>0? y : y-l0+1]
					redr
					ec ecstr
				en
				let c=getchar()
				while c!="\<leftdrag>" && c!="\<leftrelease>"
					let c=getchar()
				endwhile
			endwhile
		en
		call s:updateCursPos()
		let s0=get(t:txb.ix,bufname(''),-1)
		let t_r=line('.')/s:mapL
		echon t:txb.gridnames[s0].t_r.get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
	else
		let possav=[bufnr('%')]+getpos('.')[1:]
		call feedkeys("\<leftmouse>")
		call getchar()
		exe v:mouse_win."wincmd w"
		if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
			if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
			return "keepj norm! \<leftmouse>" | en
		exe "norm! \<leftmouse>"
		redr!
		let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
		let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(exists('g:opt_device') && g:opt_device==?'droid4' && veon)? 'redr!':'redr']
		let c=getchar()
		if c=="\<leftdrag>"
			while c=="\<leftdrag>"
				let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
				let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
				call winrestview(v)
				exe redrexpr
				let c=getchar()
			endwhile
		else
			return "keepj norm! \<leftmouse>"
		en
		if str2float(reltimestr(reltime(tl[(fr+1)%4][0])))<0.2
			let [glv,glh,vc,hc]=[tl[0][1]+tl[1][1]+tl[2][1]+tl[3][1],tl[0][2]+tl[1][2]+tl[2][2]+tl[3][2],0,0]
			let [tlx,lnx,glv,lcx,cax,glh]=(glv>3? ['y*v.topline>1','y*v.lnum>1',glv*glv] : glv<-3? ['-(y*v.topline<'.line('$').')','-(y*v.lnum<'.line('$').')',glv*glv] : [0,0,0])+(glh>3? ['x*v.leftcol>0','x*v.coladd>0',glh*glh] : glh<-3? ['-x','-x',glh*glh] : [0,0,0])
			while !getchar(1) && glv+glh
				let [y,x,vc,hc]=[vc>get(s:glidestep,glv,1),hc>get(s:glidestep,glh,1),vc+1,hc+1]
				if y||x
					let [v.topline,v.lnum,v.leftcol,v.coladd,glv,vc,glh,hc]-=[eval(tlx),eval(lnx),eval(lcx),eval(cax),y,y*vc,x,x*hc]
					call winrestview(v)
					exe redrexpr
				en
			endw
		en
		exe min([max([line('w0'),possav[1]]),line('w$')])
		let firstcol=virtcol('.')-wincol()+1
		let lastcol=firstcol+winwidth(0)-1
		let possav[3]=min([max([firstcol,possav[2]+possav[3]]),lastcol])
		exe "norm! ".possav[3]."|"
	en
	return ''
endfun
let TXBmsCmd.default=function("s:initDragDefault")

fun! s:initDragSGR()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists("t:txb")
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:mapL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
		en
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:nav_state=[line('w0'),line('.'),-10,'']
		let s:dragHandler=function("s:navPlane")
		nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
	en
	return ''
endfun
fun! <SID>doDragSGR()
	let code=[getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)]
	let k=map(split(join(map(code,'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
		if !exists('t:txb')
			return
		en
        if k[1:]==[1,1]
			call TXBdoCmd('o')
		else
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:mapL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.sgr=function("s:initDragSGR")

fun! s:initDragXterm()
	return "norm! \<leftmouse>"
endfun
let TXBmsCmd.xterm=function("s:initDragXterm")

fun! s:initDragXterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists("t:txb")
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:mapL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
		en
	elseif !exists('t:txb')
		exe v:mouse_win.'wincmd w'
		if &wrap && v:mouse_col%winwidth(0)==1
			exe "norm! \<leftmouse>"
		elseif !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol
			exe "norm! \<leftmouse>"
		else
			let s:prevCoord=[0,0,0]
			let s:dragHandler=function("s:panWin")
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let s:prevCoord=[0,0,0]
		let s:nav_state=[line('w0'),line('.'),-10,'']
		let s:dragHandler=function("s:navPlane")
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! <SID>doDragXterm2()
	let k=[getchar(0),getchar(0),getchar(0)]
	if k[0]==35
		nunmap <esc>[M
		if !exists('t:txb')
			return
		en
        if k[1:]==[33,33]
			call TXBdoCmd('o')
		else
			let s0=get(t:txb.ix,bufname(''),-1)
			let t_r=line('.')/s:mapL
			echon t:txb.gridnames[s0] t_r get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7]
		en
	elseif k[1] && k[2] && s:prevCoord[1] && s:prevCoord[2]
		call s:dragHandler(k[1]-s:prevCoord[1],k[2]-s:prevCoord[2])
	en
	let s:prevCoord=k
	while getchar(0) isnot 0
	endwhile
endfun
let TXBmsCmd.xterm2=function("s:initDragXterm2")

fun! s:panWin(dx,dy)
	exe "norm! ".(a:dy>0? get(s:mouseAcc,a:dy,s:mouseAcc[-1])."\<c-y>" : a:dy<0? get(s:mouseAcc,-a:dy,s:mouseAcc[-1])."\<c-e>" : '').(a:dx>0? (a:dx."zh") : a:dx<0? (-a:dx)."zl" : "g")
endfun
fun! s:navPlane(dx,dy)
	call s:nav(a:dx>0? -get(s:mouseAcc,a:dx,s:mouseAcc[-1]) : get(s:mouseAcc,-a:dx,s:mouseAcc[-1]))
	let l0=max([1,a:dy>0? s:nav_state[0]-get(s:mouseAcc,a:dy,s:mouseAcc[-1]) : s:nav_state[0]+get(s:mouseAcc,-a:dy,s:mouseAcc[-1])])
	exe 'norm! '.l0.'zt'
	exe 'norm! '.(s:nav_state[1]<line('w0')? 'H' : line('w$')<s:nav_state[1]? 'L' : s:nav_state[1].'G')
	let s:nav_state=[l0,line('.'),t:txb.ix[bufname('')],s:nav_state[2],s:nav_state[3]!=s:nav_state[2]? t:txb.gridnames[s:nav_state[2]].s:nav_state[1]/s:mapL.get(get(t:txb.map,s:nav_state[2],[]),s:nav_state[1]/s:mapL,'')[:&columns-7] : s:nav_state[4]]
    echon s:nav_state[4]
endfun

fun! s:getGridNames(len)
	let alpha=map(range(65,90),'nr2char(v:val)')
	let powers=[26,676,17576]
	let array1=map(range(powers[0]),'alpha[v:val%26]')
	if a:len<=powers[0]
		return array1
	elseif a:len<=powers[0]+powers[1]
		return extend(array1,map(range(a:len-powers[0]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
   	else
		call extend(array1,map(range(powers[1]),'alpha[v:val/powers[0]%26].alpha[v:val%26]'))
		return extend(array1,map(range(a:len-len(array1)),'alpha[v:val/powers[1]%26].alpha[v:val/powers[0]%26].alpha[v:val%26]'))
	en
endfun

fun! s:getMapDisp()          
	let pad=repeat(' ',&columns+20)
	let s:disp__r=s:ms__cols*s:mBlockW+1
	let l=s:disp__r*s:mBlockH
	let templist=repeat([''],s:mBlockH)
	let last_entry_colored=copy(templist)
	let s:disp__selmap=map(range(s:ms__rows),'repeat([0],s:ms__cols)')
	let dispLines=[]
	let s:disp__color=[]
	let s:disp__colorv=[]
	let extend_color='call extend(s:disp__color,'.join(map(templist,'"colorix[".v:key."]"'),'+').')'
	let extend_colorv='call extend(s:disp__colorv,'.join(map(templist,'"colorvix[".v:key."]"'),'+').')'
	let let_colorix='let colorix=['.join(map(templist,'"[]"'),',').']'
	let let_colorvix=let_colorix[:8].'v'.let_colorix[9:]
	let let_occ='let occ=['.repeat("'',",s:mBlockH)[:-2].']'
	for i in range(s:ms__rows)
		exe let_occ
		exe let_colorix
		exe let_colorvix
		for j in range(s:ms__cols)
			if !exists("s:ms__array[s:ms__coff+j][s:ms__roff+i]") || empty(s:ms__array[s:ms__coff+j][s:ms__roff+i])
				let s:disp__selmap[i][j]=[i*l+j*s:mBlockW,0]
				continue
			en
			let k=0
			let cell_border=(j+1)*s:mBlockW
			while k<s:mBlockH && len(occ[k])>=cell_border
				let k+=1
			endw
			let parsed=split(s:ms__array[s:ms__coff+j][s:ms__roff+i],'#',1)
			if k==s:mBlockH
				let k=min(map(templist,'len(occ[v:key])*30+v:key'))%30
				if last_entry_colored[k]
	                let colorix[k][-1]-=len(occ[k])-(cell_border-1)
				en
				let occ[k]=occ[k][:cell_border-2].parsed[0]
				let s:disp__selmap[i][j]=[i*l+k*s:disp__r+cell_border-1,len(parsed[0])]
			else
				let [s:disp__selmap[i][j],occ[k]]=len(occ[k])<j*s:mBlockW? [[i*l+k*s:disp__r+j*s:mBlockW,1],occ[k].pad[:j*s:mBlockW-len(occ[k])-1].parsed[0]] : [[i*l+k*s:disp__r+j*s:mBlockW+(len(occ[k])%s:mBlockW),1],occ[k].parsed[0]]
			en
			if len(parsed)>1
				call extend(colorix[k],[s:disp__selmap[i][j][0],s:disp__selmap[i][j][0]+len(parsed[0])])
				call extend(colorvix[k],['echoh NONE','echoh '.parsed[1]])
				let last_entry_colored[k]=1
			else
				let last_entry_colored[k]=0
			en
		endfor
		for z in range(s:mBlockH)
			if !empty(colorix[z]) && colorix[z][-1]%s:disp__r<colorix[z][-2]%s:disp__r
				let colorix[z][-1]-=colorix[z][-1]%s:disp__r
			en
		endfor
		exe extend_color
		exe extend_colorv
		let dispLines+=map(occ,'len(v:val)<s:ms__cols*s:mBlockW? v:val.pad[:s:ms__cols*s:mBlockW-len(v:val)-1]."\n" : v:val[:s:ms__cols*s:mBlockW-1]."\n"')
	endfor
	let s:disp__str=join(dispLines,'')
	call add(s:disp__color,99999)
	call add(s:disp__colorv,'echoh NONE')
endfun

fun! s:printMapDisp()
	let [sel,notempty]=s:disp__selmap[s:ms__r-s:ms__roff][s:ms__c-s:ms__coff]
	let colorl=len(s:disp__color)
	let p=0
	redr!
	if sel
		if sel>s:disp__color[0]
			if s:disp__color[0]
       			exe s:disp__colorv[0]
				echon s:disp__str[0 : s:disp__color[0]-1]
			en
			let p=1
			while sel>s:disp__color[p]
				exe s:disp__colorv[p]
				echon s:disp__str[s:disp__color[p-1] : s:disp__color[p]-1]
				let p+=1
			endwhile
			exe s:disp__colorv[p]
			echon s:disp__str[s:disp__color[p-1]:sel-1]
		else
   		 	exe s:disp__colorv[0]
			echon s:disp__str[:sel-1]
		en
	en
	if notempty
		let endmark=len(s:ms__array[s:ms__c][s:ms__r])
		let endmark=(sel+endmark)%s:disp__r<sel%s:disp__r? endmark-(sel+endmark)%s:disp__r-1 : endmark
		echohl TXBmapSel
		echon s:ms__array[s:ms__c][s:ms__r][:endmark-1]
		let endmark=sel+endmark
	else
		let endmark=sel+s:mBlockW
		echohl TXBmapSelEmpty
		echon s:disp__str[sel : endmark-1]
	en
	while s:disp__color[p]<endmark
		let p+=1
	endwhile
	exe s:disp__colorv[p]
	echon s:disp__str[endmark :s:disp__color[p]-1]
	for p in range(p+1,colorl-1)
		exe s:disp__colorv[p]
		echon s:disp__str[s:disp__color[p-1] : s:disp__color[p]-1]
	endfor
	echon get(t:txb.gridnames,s:ms__c,'--') s:ms__r s:ms__msg
	let s:ms__msg=''
endfun
fun! s:printMapDispNoHL()
	redr!
	let [i,len]=s:disp__selmap[s:ms__r-s:ms__roff][s:ms__c-s:ms__coff]
	echon i? s:disp__str[0 : i-1] : ''
	if len
		let len=len(s:ms__array[s:ms__c][s:ms__r])
		let len=(i+len)%s:disp__r<i%s:disp__r? len-(i+len)%s:disp__r-1 : len
		echohl TXBmapSel
		echon s:ms__array[s:ms__c][s:ms__r][:len]
	else
		let len=s:mBlockW
		echohl TXBmapSelEmpty
		echon s:disp__str[i : i+len-1]
	en
	echohl NONE
	echon s:disp__str[i+len :] get(t:txb.gridnames,s:ms__c,'--') s:ms__r s:ms__msg
	let s:ms__msg=''
endfun

fun! s:navMapKeyHandler(c)
	if a:c is -1
		if g:TXBmsmsg[0]==1
			let s:ms__prevcoord=copy(g:TXBmsmsg)
		elseif g:TXBmsmsg[0]==2
			if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
        		let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/s:mBlockH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/s:mBlockW]),0]
				let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
				call s:getMapDisp()
				call s:ms__displayfunc()
			en
			let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%s:mBlockW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%s:mBlockH]
		elseif g:TXBmsmsg[0]==3
			if g:TXBmsmsg==[3,1,1]
				let [&ch,&more,&ls,&stal]=s:ms__settings
				return
			elseif s:ms__prevcoord[0]==1
				if &ttymouse=='xterm' && s:ms__prevcoord[1]!=g:TXBmsmsg[1] && s:ms__prevcoord[2]!=g:TXBmsmsg[2] 
					if s:ms__prevcoord[1] && s:ms__prevcoord[2] && g:TXBmsmsg[1] && g:TXBmsmsg[2]
						let [s:ms__roff,s:ms__coff,s:ms__redr]=[max([0,s:ms__roff-(g:TXBmsmsg[2]-s:ms__prevcoord[2])/s:mBlockH]),max([0,s:ms__coff-(g:TXBmsmsg[1]-s:ms__prevcoord[1])/s:mBlockW]),0]
						let [s:ms__r,s:ms__c]=[s:ms__r<s:ms__roff? s:ms__roff : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__roff+s:ms__rows-1 : s:ms__r,s:ms__c<s:ms__coff? s:ms__coff : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__coff+s:ms__cols-1 : s:ms__c]
						call s:getMapDisp()
						call s:ms__displayfunc()
					en
					let s:ms__prevcoord=[g:TXBmsmsg[0],g:TXBmsmsg[1]-(g:TXBmsmsg[1]-s:ms__prevcoord[1])%s:mBlockW,g:TXBmsmsg[2]-(g:TXBmsmsg[2]-s:ms__prevcoord[2])%s:mBlockH]
				else
					let s:ms__r=(g:TXBmsmsg[2]-&lines+&ch-1)/s:mBlockH+s:ms__roff
					let s:ms__c=(g:TXBmsmsg[1]-1)/s:mBlockW+s:ms__coff
					if [s:ms__r,s:ms__c]==s:ms__prevclick
						let [&ch,&more,&ls,&stal]=s:ms__settings
						call s:doSyntax(s:gotoPos(s:ms__c,s:mapL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#',1),2,''))
						return
					en
					let s:ms__prevclick=[s:ms__r,s:ms__c]
					let s:ms__prevcoord=[0,0,0]
					let [roffn,coffn]=[s:ms__r<s:ms__roff? s:ms__r : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__r-s:ms__rows+1 : s:ms__roff,s:ms__c<s:ms__coff? s:ms__c : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__c-s:ms__cols+1 : s:ms__coff]
					if [s:ms__roff,s:ms__coff]!=[roffn,coffn] || s:ms__redr
						let [s:ms__roff,s:ms__coff,s:ms__redr]=[roffn,coffn,0]
						call s:getMapDisp()
					en
					call s:ms__displayfunc()
				en
			en
		en
		call feedkeys("\<plug>TxbY")
	else
		exe get(s:mapdict,a:c,'let s:ms__msg=" Press f1 for help or q to quit"')
		if s:ms__continue==1
			let [roffn,coffn]=[s:ms__r<s:ms__roff? s:ms__r : s:ms__r>=s:ms__roff+s:ms__rows? s:ms__r-s:ms__rows+1 : s:ms__roff,s:ms__c<s:ms__coff? s:ms__c : s:ms__c>=s:ms__coff+s:ms__cols? s:ms__c-s:ms__cols+1 : s:ms__coff]
			if [s:ms__roff,s:ms__coff]!=[roffn,coffn] || s:ms__redr
				let [s:ms__roff,s:ms__coff,s:ms__redr]=[roffn,coffn,0]
				call s:getMapDisp()
			en
			call s:ms__displayfunc()
			call feedkeys("\<plug>TxbY")
		elseif s:ms__continue==2
			let [&ch,&more,&ls,&stal]=s:ms__settings
			call s:doSyntax(s:gotoPos(s:ms__c,s:mapL*s:ms__r)? '' : get(split(get(get(s:ms__array,s:ms__c,[]),s:ms__r,''),'#',1),2,''))
		else
			let [&ch,&more,&ls,&stal]=s:ms__settings
		en
	en
endfun

fun! s:doSyntax(stmt)
	if empty(a:stmt)
		return
	en
	let num=''
	let com={'s':0,'r':0,'R':0,'j':0,'k':0,'l':0,'C':0,'M':0,'W':0}
	for t in range(len(a:stmt))
		if a:stmt[t]=~'\d'
			let num.=a:stmt[t]
		elseif has_key(com,a:stmt[t])
			let com[a:stmt[t]]+=empty(num)? 1 : num
			let num=''
		else
			echoerr '"'.a:stmt[t].'" is not a recognized command, view positioning aborted.'
			return
		en
	endfor
	exe 'norm! '.(com.j>com.k? (com.j-com.k).'j' : com.j<com.k? (com.k-com.j).'k' : '').(com.l>winwidth(0)? 'g$' : com.l? com.l .'|' : '').(com.M>0? 'zz' : com.r>com.R? (com.r-com.R)."\<c-e>" : com.r<com.R? (com.R-com.r)."\<c-y>" : 'g')
	if com.C
		call s:nav(wincol()-&columns/2)
	elseif com.s
		call s:nav(-min([eval(join(map(range(s:ms__c-1,s:ms__c-com.s,-1),'1+t:txb.size[(v:val+t:txb.len)%t:txb.len]'),'+')),!com.W? &columns-winwidth(0) : &columns>com.W? &columns-com.W : 0]))
	en
endfun

let TXBkyCmd.o='let s:kc__continue=0|cal s:navMap(t:txb.map,t:txb.ix[expand("%")],line(".")/s:mapL)'
fun! s:navMap(array,c_ini,r_ini)
	let s:ms__num='01'
	let curspos=[line('.')%s:mapL,virtcol('.')-1]
	let s:ms__posmes=(curspos!=[0,0])? "\n(".(curspos[0]? curspos[0].'j' : '').(curspos[1]? curspos[1].'l' : '').' will set jump target at cursor position)' : ''
	let s:ms__initbk=[a:r_ini,a:c_ini]
	let s:ms__settings=[&ch,&more,&ls,&stal]
		let [&more,&ls,&stal]=[0,0,0]
		let &ch=&lines
	let s:ms__prevclick=[0,0]
	let s:ms__prevcoord=[0,0,0]
	let s:ms__array=a:array
	let s:ms__msg=''
	let s:ms__r=a:r_ini
	let s:ms__c=a:c_ini
	let s:ms__continue=1
	let s:ms__redr=1
	let s:ms__rows=(&ch-1)/s:mBlockH
	let s:ms__cols=(&columns-1)/s:mBlockW
	let s:ms__roff=max([s:ms__r-s:ms__rows/2,0])
	let s:ms__coff=max([s:ms__c-s:ms__cols/2,0])
	let s:ms__displayfunc=function('s:printMapDisp')
   	call s:getMapDisp()
	call s:ms__displayfunc()
	let g:TXBkeyhandler=function("s:navMapKeyHandler")
	call feedkeys("\<plug>TxbY")
endfun
let s:last_yanked_is_column=0
let s:mapdict={"\e":"let s:ms__continue=0|redr",
\"\<f1>":'let width=&columns>80? min([&columns-10,80]) : &columns-2|cal s:pager(s:formatPar("\n\n\\CMap Help\n\nKeyboard: (Each map grid is 1 split x ".s:mapL." lines)
\\n    h j k l                   move 1 block cardinally*
\\n    y u b n                   move 1 block diagonally*
\\n    0 $                       Beginning / end of line
\\n    H M L                     High / Middle / Low of screen
\\n    x                         clear and obtain cell
\\n    o O                       obtain cell / Obtain column
\\n    p P                       Put obtained cell or column
\\n    c i                       Change label
\\n    g <cr>                    Goto block (and exit map)
\\n    I D                       Insert / Delete and obtain column
\\n    Z                         Adjust map block size
\\n    T                         Toggle color
\\n    q                         Quit
\\n*The movement commands take counts, as in vim. Eg, 3j will move down 3 rows. The count is capped at 99.
\\n\nMouse:
\\n    doubleclick               Goto block
\\n    drag                      Pan
\\n    click at topleft corner   Quit
\\n    drag to topleft corner    Show map
\\n\nMouse clicks are associated with the very first letter of the label, so it might be helpful to prepend a marker, eg, ''+ Chapter 1'', so you can aim your mouse at the ''+''. To facilitate navigating with the mouse only, the map can be activated with a mouse drag that ends at the top left corner; it can be closed by a click at the top left corner.
\\n\nMouse commands only work when ttymouse is set to xterm2 or sgr. When ttymouse is xterm, a limited set of features will work.
\\n\n\\CAdvanced - Map Label Syntax
\\n\nSyntax is provided for map labels in order to (1) color labels and (2) allow for additional positioning after jumping to the target block. Syntax hints can also optionally be shown during the change label input (''c'' or ''i''). The ''#'' character is reserved to designated syntax regions and, unfortunately, can never be used in the label itself.
\\n\nColoring:
\\n\nColor a label via the syntax ''label_text#highlightgroup''. For example, ''^ Danger!#WarningMsg'' should color the label bright red. If coloring is causing slowdowns or drawing issues, you can toggle it with the ''T'' command.
\\n\nPositioning:
\\n\nBy default, jumping to the target grid will put the cursor at the top left corner and the split as the leftmost split. The commands following the second ''#'' character can change this. To shift the view but skip highlighting use two ''#'' characters. For example, ''^ Danger!##CM'' will [C]enter the cursor horizontally and put it in the [M]iddle of the screen. The full command list is:
\\n\n    jkl    Move the cursor as in vim 
\\n    s      Shift view left 1 split
\\n    r R    Shift view down / up 1 row (1 line)
\\n    C      Shift view so that cursor is Centered horizontally
\\n    M      Shift view so that cursor is at the vertical Middle of the screen
\\n    W      Determines maximum s shift (see below)
\\n\nThese commands work much like normal mode commands. For example, ''^ Danger!#WarningMsg#sjjj'' or ''^ Danger!#WarningMsg#s3j'' will both shift the view left by one split and move the cursor down 3 lines. The order of the commands does not matter.
\\n\nBy default, ''s'' won''t move the split offscreen. For example, ''45s'' will not actually pan left 45 splits but only enough to push the target split to the right edge. This behavior can be modified by including the ''W'' command, which specifies a ''virtual width''. For example, ''30W'' means that the width of the split is treated as though it were 30 columns. This would cause ''2s30W'' to shift only up to the point where 30 columns of the split are visible (and usually less than that)."
\,width,(&columns-width)/2))',
\"q":"let s:ms__continue=0",
\"l":"let s:ms__c+=s:ms__num|let s:ms__num='01'",
\"h":"let s:ms__c=max([s:ms__c-s:ms__num,0])|let s:ms__num='01'",
\"j":"let s:ms__r+=s:ms__num|let s:ms__num='01'",
\"k":"let s:ms__r=max([s:ms__r-s:ms__num,0])|let s:ms__num='01'",
\"y":"let [s:ms__r,s:ms__c]=[max([s:ms__r-s:ms__num,0]),max([s:ms__c-s:ms__num,0])]|let s:ms__num='01'",
\"u":"let [s:ms__r,s:ms__c]=[max([s:ms__r-s:ms__num,0]),s:ms__c+s:ms__num]|let s:ms__num='01'",
\"b":"let [s:ms__r,s:ms__c]=[s:ms__r+s:ms__num,max([s:ms__c-s:ms__num,0])]|let s:ms__num='01'",
\"n":"let [s:ms__r,s:ms__c]=[s:ms__r+s:ms__num,s:ms__c+s:ms__num]|let s:ms__num='01'",
\"1":"let s:ms__num=s:ms__num is '01'? '1' : s:ms__num>98? s:ms__num : s:ms__num.'1'",
\"2":"let s:ms__num=s:ms__num is '01'? '2' : s:ms__num>98? s:ms__num : s:ms__num.'2'",
\"3":"let s:ms__num=s:ms__num is '01'? '3' : s:ms__num>98? s:ms__num : s:ms__num.'3'",
\"4":"let s:ms__num=s:ms__num is '01'? '4' : s:ms__num>98? s:ms__num : s:ms__num.'4'",
\"5":"let s:ms__num=s:ms__num is '01'? '5' : s:ms__num>98? s:ms__num : s:ms__num.'5'",
\"6":"let s:ms__num=s:ms__num is '01'? '6' : s:ms__num>98? s:ms__num : s:ms__num.'6'",
\"7":"let s:ms__num=s:ms__num is '01'? '7' : s:ms__num>98? s:ms__num : s:ms__num.'7'",
\"8":"let s:ms__num=s:ms__num is '01'? '8' : s:ms__num>98? s:ms__num : s:ms__num.'8'",
\"9":"let s:ms__num=s:ms__num is '01'? '9' : s:ms__num>98? s:ms__num : s:ms__num.'9'",
\"0":"let [s:ms__c,s:ms__num]=s:ms__num is '01'? [s:ms__coff,s:ms__num] : [s:ms__c,s:ms__num>998? s:ms__num : s:ms__num.'0']",
\"$":"let s:ms__c=s:ms__coff+s:ms__cols-1",
\"H":"let s:ms__r=s:ms__roff",
\"M":"let s:ms__r=s:ms__roff+s:ms__rows/2",
\"L":"let s:ms__r=s:ms__roff+s:ms__rows-1",
\"T":"let s:ms__displayfunc=s:ms__displayfunc==function('s:printMapDisp')? function('s:printMapDispNoHL') : function('s:printMapDisp')",
\"x":"if exists('s:ms__array[s:ms__c][s:ms__r]')|let @\"=s:ms__array[s:ms__c][s:ms__r]|let s:ms__array[s:ms__c][s:ms__r]=''|let s:ms__redr=1|en",
\"o":"if exists('s:ms__array[s:ms__c][s:ms__r]')|let @\"=s:ms__array[s:ms__c][s:ms__r]|let s:ms__msg=' Cell obtained'|let s:last_yanked_is_column=0|en",
\"p":"if s:last_yanked_is_column\n
	\if s:ms__c+1>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+2-len(s:ms__array)),',').']'))\n
	\en\n
	\call insert(s:ms__array,s:copied_column,s:ms__c+1)\n
	\let s:ms__redr=1\n
\else\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\if s:ms__r>=len(s:ms__array[s:ms__c])\n
		\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
	\en\n
	\let s:ms__array[s:ms__c][s:ms__r]=@\"\n
	\let s:ms__redr=1\n
\en",
\"P":"if s:last_yanked_is_column\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\call insert(s:ms__array,s:copied_column,s:ms__c)\n
	\let s:ms__redr=1\n
\else\n
	\if s:ms__c>=len(s:ms__array)\n
		\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
	\en\n
	\if s:ms__r>=len(s:ms__array[s:ms__c])\n
		\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
	\en\n
	\let s:ms__array[s:ms__c][s:ms__r]=@\"\n
	\let s:ms__redr=1\n
\en",
\"c":"let input=input(s:disp__str.(exists('s:show_syntax_help')? 'label text#highlight group#post jump positioning commands\n   jkl  move cursor                 s    shift one split left\n   r    shift one row down          R    shift one row up\n   C    center cursor horizontally  M    center cursor vertically' : '').([s:ms__r,s:ms__c]==s:ms__initbk? s:ms__posmes : '').'\nChange (type \"##hint\" to toggle syntax hints): ',exists('s:ms__array[s:ms__c][s:ms__r]')? s:ms__array[s:ms__c][s:ms__r] : '')\n
\if !empty(input)\n
	\if input==?'##hint'\n
		\if exists('s:show_syntax_help')\n
			\unlet s:show_syntax_help\n
		\else\n
			\let s:show_syntax_help=1\n
		\en\n
		\exe s:mapdict.c\n
	\else\n
		\if s:ms__c>=len(s:ms__array)\n
			\call extend(s:ms__array,eval('['.join(repeat(['[]'],s:ms__c+1-len(s:ms__array)),',').']'))\n
		\en\n
		\if s:ms__r>=len(s:ms__array[s:ms__c])\n
			\call extend(s:ms__array[s:ms__c],repeat([''],s:ms__r+1-len(s:ms__array[s:ms__c])))\n
		\en\n
		\let s:ms__array[s:ms__c][s:ms__r]=strtrans(input)\n
		\let s:ms__redr=1\n
	\en\n
\en\n",
\"g":'let s:ms__continue=2',
\"Z":'let s:mBlockW=min([10,max([1,input(s:disp__str."\nBlock width (1-10): ",s:mBlockW)])])|let s:mBlockH=min([10,max([1,input("\nBlock height (1-10): ",s:mBlockH)])])|let [s:ms__redr,s:ms__rows,s:ms__cols]=[1,(&ch-1)/s:mBlockH,(&columns-1)/s:mBlockW]',
\"I":'if s:ms__c<len(s:ms__array)|call insert(s:ms__array,[],s:ms__c)|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." inserted"|en',
\"D":'if s:ms__c<len(s:ms__array) && input(s:disp__str."\nReally delete column? (y/n)")==?"y"|let s:copied_column=remove(s:ms__array,s:ms__c)|let s:last_yanked_is_column=1|let s:ms__redr=1|let s:ms__msg="Col ".(s:ms__c)." deleted"|en',
\"O":'let s:copied_column=s:ms__c<len(s:ms__array)? deepcopy(s:ms__array[s:ms__c]) : []|let s:ms__msg=" Col ".(s:ms__c)." Obtained"|let s:last_yanked_is_column=1'}
let s:mapdict.i=s:mapdict.c
let s:mapdict["\<c-m>"]=s:mapdict.g

fun! s:deleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun
	let TXBkyCmd["\<c-x>"]='cal s:deleteHiddenBuffers()|let [s:kc__msg,s:kc__continue]=["Hidden Buffers Deleted",0]'

fun! s:formatPar(str,w,pad)
	let [pars,pad,bigpad,spc]=[split(a:str,"\n",1),repeat(" ",a:pad),repeat(" ",a:w+10),repeat(' ',len(&brk))]
	let ret=[]
	for k in range(len(pars))
		if pars[k][0]==#'\'
			let format=pars[k][1]
   			let pars[k]=pars[k][(format=='\'? 1 : 2):]
		else
			let format=''
		en
		let seg=[0]
		while seg[-1]<len(pars[k])-a:w
			let ix=(a:w+strridx(tr(pars[k][seg[-1]:seg[-1]+a:w-1],&brk,spc),' '))%a:w
			call add(seg,seg[-1]+ix-(pars[k][seg[-1]+ix=~'\s']))
			let ix=seg[-2]+ix+1
			while pars[k][ix]==" "
				let ix+=1
			endwhile
			call add(seg,ix)
		endw
		call add(seg,len(pars[k])-1)
		let ret+=map(range(len(seg)/2),format==#'C'? 'pad.bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)/2].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : format==#'R'? 'pad.bigpad[1:(a:w-seg[2*v:val+1]+seg[2*v:val]-1)].pars[k][seg[2*v:val]:seg[2*v:val+1]]' : 'pad.pars[k][seg[2*v:val]:seg[2*v:val+1]]')
	endfor
	return ret
endfun

fun! s:pager(list)
	let more=&more
	se nomore
	let [pos,next,bot,continue]=[-1,0,max([len(a:list)-&lines+1,0]),1]
	while continue
		if pos!=next
			let pos=next
			redr|echo join(a:list[pos : pos+&lines-1],"\n")."\nSPACE/d/j:down, b/u/k: up, g/G:top/bottom, q:quit"
		en
		exe get(s:pagercom,getchar(),'')
	endwhile
	redr
	let &more=more
endfun
let s:pagercom={113:'let continue=0',27:'let continue=0',
\32:'let next=pos+&lines/2<bot? pos+&lines/2 : bot',
\100:'let next=pos+&lines/2<bot? pos+&lines/2 : bot',
\106:'let next=pos<bot? pos+1 : pos',
\107:'let next=pos>0? pos-1 : pos',
\98:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\117:'let next=pos-&lines/2>0? pos-&lines/2 : 0',
\103:'let next=0',
\71:'let next=bot'}

fun! s:gotoPos(col,row)
	let name=get(t:txb.name,a:col,-1)
	if name==-1
		echoerr "Split ".a:col." does not exist."
		return 1
	elseif name!=#expand('%')
		wincmd t
		exe 'e '.escape(name,' ')
	en
	norm! 0
	only
	call TXBload()
	exe 'norm!' (a:row? a:row : 1).'zt'
endfun

fun! s:blockPan(dx,y,...)
	let cury=line('w0')
	let absolute_x=exists('a:1')? a:1 : 0
	let dir=absolute_x? absolute_x : a:dx
	let y=a:y>cury?  (a:y-cury-1)/s:panL+1 : a:y<cury? -(cury-a:y-1)/s:panL-1 : 0
   	let update_ydest=y>=0? 'let y_dest=!y? cury : cury/'.s:panL.'*'.s:panL.'+'.s:panL : 'let y_dest=!y? cury : cury>'.s:panL.'? (cury-1)/'.s:panL.'*'.s:panL.' : 1'
	let pan_y=(y>=0? 'let cury=cury+'.s:aniStepV.'<y_dest? cury+'.s:aniStepV.' : y_dest' : 'let cury=cury-'.s:aniStepV.'>y_dest? cury-'.s:aniStepV.' : y_dest')."\n
		\if cury>line('$')\n
			\let longlinefound=0\n
			\for i in range(winnr('$')-1)\n
				\wincmd w\n
				\if line('$')>=cury\n
					\exe 'norm!' cury.'zt'\n
					\let longlinefound=1\n
					\break\n
				\en\n
			\endfor\n
			\if !longlinefound\n
				\exe 'norm! Gzt'\n
			\en\n
		\else\n
			\exe 'norm!' cury.'zt'\n
		\en"
	if dir>0
		let i=0
		let continue=1
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			while winwidth(1)>s:aniStepH
				call s:nav(s:aniStepH)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:nav(winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i+=1
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i<a:dx
		endwhile
	elseif dir<0
		let i=0
		let continue=!map([t:txb.ix[bufname(winbufnr(1))]],'absolute_x && v:val==a:dx && winwidth(1)>=t:txb.size[v:val]')[0]
		while continue
			exe update_ydest
			let buf0=winbufnr(1)
			let ix=t:txb.ix[bufname(buf0)]
			if winwidth(1)>=t:txb.size[ix]
				call s:nav(-4)
				let buf0=winbufnr(1)
			en
			while winwidth(1)<t:txb.size[ix]-s:aniStepH
				call s:nav(-s:aniStepH)
				exe pan_y
				redr
			endwhile
			if winbufnr(1)==buf0
				call s:nav(-t:txb.size[ix]+winwidth(1))
			en
			while cury!=y_dest
				exe pan_y
				redr
			endwhile
			let y+=y>0? -1 : y<0? 1 : 0
			let i-=1
			let continue=absolute_x? (t:txb.ix[bufname(winbufnr(1))]==a:dx? 0 : 1) : i>a:dx
		endwhile
	en
	while y
		exe update_ydest
		while cury!=y_dest
			exe pan_y
			redr
		endwhile
		let y+=y>0? -1 : y<0? 1 : 0
	endwhile
endfun
let s:Y1='let s:kc__y=s:kc__y/s:panL*s:panL+s:kc__num*s:panL|'
let s:Ym1='let s:kc__y=max([1,s:kc__y/s:panL*s:panL-s:kc__num*s:panL])|'
	let TXBkyCmd.h='cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)'
	let TXBkyCmd.j=s:Y1.'cal s:blockPan(0,s:kc__y)|let s:kc__num="01"|call s:updateCursPos()'
	let TXBkyCmd.k=s:Ym1.'cal s:blockPan(0,s:kc__y)|let s:kc__num="01"|call s:updateCursPos()' 
	let TXBkyCmd.l='cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
	let TXBkyCmd.y=s:Ym1.'cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)' 
	let TXBkyCmd.u=s:Ym1.'cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
	let TXBkyCmd.b =s:Y1.'cal s:blockPan(-s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(1)' 
	let TXBkyCmd.n=s:Y1.'cal s:blockPan(s:kc__num,s:kc__y)|let s:kc__num="01"|call s:updateCursPos(-1)' 
let TXBkyCmd.1="let s:kc__num=s:kc__num is '01'? '1' : s:kc__num>98? s:kc__num : s:kc__num.'1'"
let TXBkyCmd.2="let s:kc__num=s:kc__num is '01'? '2' : s:kc__num>98? s:kc__num : s:kc__num.'2'"
let TXBkyCmd.3="let s:kc__num=s:kc__num is '01'? '3' : s:kc__num>98? s:kc__num : s:kc__num.'3'"
let TXBkyCmd.4="let s:kc__num=s:kc__num is '01'? '4' : s:kc__num>98? s:kc__num : s:kc__num.'4'"
let TXBkyCmd.5="let s:kc__num=s:kc__num is '01'? '5' : s:kc__num>98? s:kc__num : s:kc__num.'5'"
let TXBkyCmd.6="let s:kc__num=s:kc__num is '01'? '6' : s:kc__num>98? s:kc__num : s:kc__num.'6'"
let TXBkyCmd.7="let s:kc__num=s:kc__num is '01'? '7' : s:kc__num>98? s:kc__num : s:kc__num.'7'"
let TXBkyCmd.8="let s:kc__num=s:kc__num is '01'? '8' : s:kc__num>98? s:kc__num : s:kc__num.'8'"
let TXBkyCmd.9="let s:kc__num=s:kc__num is '01'? '9' : s:kc__num>98? s:kc__num : s:kc__num.'9'"
let TXBkyCmd.0="let s:kc__num=s:kc__num is '01'? '01' : s:kc__num>98? s:kc__num : s:kc__num.'1'"

fun! s:snapToGrid()
	let [ix,l0]=[t:txb.ix[expand('%')],line('.')]
	let y=l0>s:mapL? l0-l0%s:mapL : 1
	let poscom=get(split(get(get(t:txb.map,ix,[]),l0/s:mapL,''),'#',1),2,'')
	if !empty(poscom)
		call s:doSyntax(s:gotoPos(ix,y)? '' : poscom)
		call s:saveCursPos()
	elseif winnr()!=winnr('$')
		exe 'norm! '.y.'zt0'
		call TXBload()
	elseif t:txb.size[ix]>&columns
		only
		exe 'norm! '.y.'zt0'
	elseif winwidth(0)<t:txb.size[ix]
		call s:nav(-winwidth(0)+t:txb.size[ix]) 
		exe 'norm! '.y.'zt0'
	elseif winwidth(0)>t:txb.size[ix]
		exe 'norm! '.y.'zt0'
		call TXBload()
	en
endfun
let TXBkyCmd['.']='call s:snapToGrid()|let s:kc__continue=0|call s:updateCursPos()' 

nmap <silent> <plug>TxbY<esc>[ :call <SID>getmouse()<cr>
nmap <silent> <plug>TxbY :call <SID>getchar()<cr>
nmap <silent> <plug>TxbZ :call <SID>getchar()<cr>
fun! <SID>getchar()
	if getchar(1) is 0
		sleep 1m
		call feedkeys("\<plug>TxbY")
	else
		call s:dochar()
	en
endfun
"mouse    leftdown leftdrag leftup
"xterm    32                35
"xterm2   32       64       35
"sgr      0M       32M      0m 
"TXBmsmsg 1        2        3            else 0
fun! <SID>getmouse()
	if &ttymouse=~?'xterm'
		let g:TXBmsmsg=[getchar(0)*0+getchar(0),getchar(0)-32,getchar(0)-32]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==64? 2 : g:TXBmsmsg[0]==32? 1 : g:TXBmsmsg[0]==35? 3 : 0
	elseif &ttymouse==?'sgr'
		let g:TXBmsmsg=split(join(map([getchar(0)*0+getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';')
		let g:TXBmsmsg=len(g:TXBmsmsg)> 2? [str2nr(g:TXBmsmsg[0]).g:TXBmsmsg[2][len(g:TXBmsmsg[2])-1],str2nr(g:TXBmsmsg[1]),str2nr(g:TXBmsmsg[2])] : [0,0,0]
		let g:TXBmsmsg[0]=g:TXBmsmsg[0]==#'32M'? 2 : g:TXBmsmsg[0]==#'0M'? 1 : (g:TXBmsmsg[0]==#'0m' || g:TXBmsmsg[0]==#'32K') ? 3 : 0
	else
		let g:TXBmsmsg=[0,0,0]
	en
	while getchar(0) isnot 0
	endwhile
	call g:TXBkeyhandler(-1)	
endfun
fun! s:dochar()
	let [k,c]=['',getchar()]
	while c isnot 0
		let k.=type(c)==0? nr2char(c) : c
		let c=getchar(0)
	endwhile
	call g:TXBkeyhandler(k)
endfun

fun! TXBdoCmd(inicmd)
	let s:kc__num='01'
   	let s:kc__y=line('w0')
	let s:kc__continue=1
	let s:kc__msg=''
	call s:saveCursPos()
	let g:TXBkeyhandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:inicmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:TXBkyCmd,a:c,'let s:kc__msg=" Press f1 for help"')
	if s:kc__continue
		let s0=get(t:txb.ix,bufname(''),-1)
		let t_r=line('.')/s:mapL
		echon t:txb.gridnames[s0] t_r empty(s:kc__msg)? get(get(t:txb.map,s0,[]),t_r,'')[:&columns-7] : s:kc__msg
		let s:kc__msg=''
		call feedkeys("\<plug>TxbZ") 
	elseif !empty(s:kc__msg)
		ec s:kc__msg
	en
endfun

let TXBkyCmd[-1]='let s:kc__continue=0|call feedkeys("\<leftmouse>")'
let TXBkyCmd.ini=""
let TXBkyCmd.D="redr\n
\let confirm=input(' < Really delete current column (y/n)? ')\n
\if confirm==?'y'\n
	\let ix=get(t:txb.ix,expand('%'),-1)\n
	\if ix!=-1\n
		\call TXBdeleteCol(ix)\n
		\wincmd W\n
		\call TXBload(t:txb)\n
		\let s:kc__msg='col '.ix.' removed'\n
	\else\n
		\let s:kc__msg='Current buffer not in plane; deletion failed'\n
	\en\n
\en\n
\let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd.A="let ix=get(t:txb.ix,expand('%'),-1)\n
\if ix!=-1\n
	\redr\n
	\let file=input(' < File to append : ',substitute(bufname('%'),'\\d\\+','\\=(\"000000\".(str2nr(submatch(0))+1))[-len(submatch(0)):]',''),'file')\n
	\let error=s:appendSplit(ix,file)\n
	\if empty(error)\n
		\try\n
			\call TXBload(t:txb)\n
			\let s:kc__msg='col '.(ix+1).' appended'\n
		\catch\n
			\call TXBdeleteCol(ix)\n
			\let s:kc__msg='Error detected while loading plane: file append aborted'\n
		\endtry\n
	\else\n
		\let s:kc__msg='Error: '.error\n
	\en\n
\else\n
	\let s:kc__msg='Current buffer not in plane'\n
\en\n
\let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd["\e"]="let s:kc__continue=0"
let TXBkyCmd.q="let s:kc__continue=0"
let TXBkyCmd.r="call TXBload(t:txb)|redr|let s:kc__msg='(redrawn)'|let s:kc__continue=0|call s:updateCursPos()" 
let TXBkyCmd["\<f1>"]='call s:printHelp()|let s:kc__continue=0'
let TXBkyCmd.E='call s:editSplitSettings()|let s:kc__continue=0'

fun! s:editSplitSettings()
   	let ix=get(t:txb.ix,expand('%'),-1)
	if ix==-1
		ec " Error: Current buffer not in plane"
	else
		redr
		let input=input('Column width: ',t:txb.size[ix])
		if empty(input) | return | en
    	let t:txb.size[ix]=input
    	let input=input("Autoexecute on load: ",t:txb.exe[ix])
		if empty(input) | return | en
		let t:txb.exe[ix]=input
    	let input=input('Column position (0-'.(t:txb.len-1).'): ',ix)
		if empty(input) | return | en
		let newix=input
		if newix>=0 && newix<t:txb.len && newix!=ix
			let item=remove(t:txb.name,ix)
			call insert(t:txb.name,item,newix)
			let item=remove(t:txb.size,ix)
			call insert(t:txb.size,item,newix)
			let item=remove(t:txb.exe,ix)
			call insert(t:txb.exe,item,newix)
			let [t:txb.ix,i]=[{},0]
			for e in t:txb.name
				let [t:txb.ix[e],i]=[i,i+1]
			endfor
		en
		call TXBload(t:txb)
	en
endfun

fun! s:appendSplit(index,file,...)
	if empty(a:file)
		return 'File name is empty'
	elseif has_key(t:txb.ix,a:file)
		return 'Duplicate entries not allowed'
	en
	call insert(t:txb.name,a:file,a:index+1)
	call insert(t:txb.size,exists('a:1')? a:1 : 60,a:index+1)
	call insert(t:txb.exe,'se nowrap scb cole=2',a:index+1)
	let t:txb.len=len(t:txb.name)
	let [t:txb.ix,i]=[{},0]
	for e in t:txb.name
		let [t:txb.ix[e],i]=[i,i+1]
	endfor
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:getGridNames(t:txb.len+50)
	endif
endfun

fun! TXBload(...)
	if a:0
		let t:txb=a:1
	elseif !exists("t:txb")
		ec "No plane initialized..."
		return
	en
	let [col0,win0]=[get(t:txb.ix,bufname(""),a:0? -1 : -2),winnr()]
	if col0==-2
		ec "Current buffer not registered in in plane, use ".s:hkName."A to add"
		return
	elseif col0==-1
		let col0=0
		only
		let name=t:txb.name[0]
		if name!=#expand('%')
			exe 'e '.escape(name,' ')
		en
	en
	let pos=[bufnr('%'),line('w0')]
	exe winnr()==1? "norm! mt" : "norm! mt0"
	let alignmentcmd="norm! 0".pos[1]."zt"
	se scrollopt=jump
	if winnr()==1 && !&wrap
		let offset=virtcol('.')-wincol()
		if offset<t:txb.size[col0]
			exe (t:txb.size[col0]-offset).'winc|'
		en
	en
	let [split0,colt,colsLeft]=[win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2,col0,0]
	let remain=split0
	while remain>=1
		let colt=(colt-1)%t:txb.len
		let remain-=t:txb.size[colt]+1
		let colsLeft+=1
	endwhile
	let [colb,remain,colsRight]=[col0,&columns-(split0>0? split0+1+t:txb.size[col0] : min([winwidth(1),t:txb.size[col0]])),1]
	while remain>=2
		let remain-=t:txb.size[colb]+1
		let colb=(colb+1)%t:txb.len
		let colsRight+=1
	endwhile
	let colbw=t:txb.size[colb]+remain
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(col0-win0)%t:txb.len
		for i in range(dif)
			let colt=(colt-1)%t:txb.len
			exe 'top vsp '.escape(t:txb.name[colt],' ')
			exe alignmentcmd
			exe t:txb.exe[colt]
			se wfw
		endfor
	elseif dif<0
		wincmd t
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	let dif=colsRight+colsLeft-winnr('$')
	if dif>0
		let colb=(col0+colsRight-1-dif)%t:txb.len
		for i in range(dif)
			let colb=(colb+1)%t:txb.len
			exe 'bot vsp '.escape(t:txb.name[colb],' ')
			exe alignmentcmd
			exe t:txb.exe[colb]
			se wfw
		endfor
	elseif dif<0
		wincmd b
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	windo se nowfw
	wincmd =
	wincmd b
	let [bot,cwin]=[winnr(),-1]
	while winnr()!=cwin
		se wfw
		let [cwin,ccol]=[winnr(),(colt+winnr()-1)%t:txb.len]
		let k=t:txb.name[ccol]
		if expand('%:p')!=#fnamemodify(t:txb.name[ccol],":p")
			exe 'e' escape(t:txb.name[ccol],' ')
			exe alignmentcmd
			exe t:txb.exe[ccol]
		elseif a:0
			exe alignmentcmd
			exe t:txb.exe[ccol]
		en
		if cwin==1
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		else
			let dif=(cwin==bot? colbw : t:txb.size[ccol])-winwidth(cwin)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
		en
		wincmd h
	endw
	se scrollopt=ver,jump
	try
	exe "silent norm! :syncbind\<cr>"
	catch
	endtry
   	exe "norm!" bufwinnr(pos[0])."\<c-w>w".pos[1]."zt`t"
	if len(t:txb.gridnames)<t:txb.len
		let t:txb.gridnames=s:getGridNames(t:txb.len+50)
	en
endfun

fun! s:saveCursPos()
	let s:cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun
fun! s:updateCursPos(...)
    let default_scrolloff=a:0? a:1 : 0
	let win=bufwinnr(s:cPos[0])
	if win!=-1
		if winnr('$')==1 || win==1
			winc t
			let offset=virtcol('.')-wincol()+1
			let width=offset+winwidth(0)-3
			exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(s:cPos[2]<offset? offset : width<=s:cPos[2]? width : s:cPos[2]).'|'
		elseif win!=1
			exe win.'winc w'
			exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(s:cPos[2]>winwidth(win)? '0g$' : s:cPos[2].'|')
		en
	elseif default_scrolloff==1 || !default_scrolloff && t:txb.ix[bufname(s:cPos[0])]>t:txb.ix[bufname('')]
		winc b
		exe 'norm! '.(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').(winnr('$')==1? 'g$' : '0g$')
	else
		winc t
		exe "norm! ".(s:cPos[1]<line('w0')? 'H' : line('w$')<s:cPos[1]? 'L' : s:cPos[1].'G').'g0'
	en
	let s:cPos=[bufnr('%'),line('.'),virtcol('.')]
endfun

fun! s:nav(N)
	let c_bf=bufnr('')
	let c_vc=virtcol('.')
	let alignmentcmd='norm! '.line('w0').'zt'
	if a:N<0
		let N=-a:N
		let extrashift=0
		let tcol=t:txb.ix[bufname(winbufnr(1))]
		if N<&columns
			while winwidth(winnr('$'))<=N
				wincmd b
				let extrashift=(winwidth(0)==N)
				hide
			endw
		else
			wincmd t
			only
		en
		if winwidth(0)!=&columns
			wincmd t	
			if winwidth(winnr('$'))<=N+3+extrashift || winnr('$')>=9
				se nowfw
				wincmd b
				exe 'vert res-'.(N+extrashift)
				wincmd t
				if winwidth(1)==1
					wincmd l
					se nowfw
					wincmd t 
					exe 'vert res+'.(N+extrashift)
					wincmd l
					se wfw
					wincmd t
				else
					exe 'vert res+'.(N+extrashift)
				en
				se wfw
			else
				exe 'vert res+'.(N+extrashift)
			en
			while winwidth(0)>=t:txb.size[tcol]+2
				se nowfw scrollopt=jump
				let nextcol=(tcol-1)%t:txb.len
				exe 'top '.(winwidth(0)-t:txb.size[tcol]-1).'vsp '.escape(t:txb.name[nextcol],' ')
				exe alignmentcmd
				exe t:txb.exe[nextcol]
				wincmd l
				se wfw
				norm! 0
				wincmd t
				let tcol=nextcol
				se wfw scrollopt=ver,jump
			endwhile
			let offset=t:txb.size[tcol]-winwidth(0)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				winc b
				norm! 0g$
			elseif c_wn!=1
				exe c_wn.'winc w'
				exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
			en
		else
			let loff=&wrap? -N-extrashift : virtcol('.')-wincol()-N-extrashift
			if loff>=0
				exe 'norm! '.(N+extrashift).(bufwinnr(c_bf)==-1? 'zhg$' : 'zh')
			else
				let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
				while loff<=-2
					let tcol=(tcol-1)%t:txb.len
					let loff+=t:txb.size[tcol]+1
				endwhile
				se scrollopt=jump
				exe 'e '.escape(t:txb.name[tcol],' ')
				exe alignmentcmd
				exe t:txb.exe[tcol]
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&columns-1
					let spaceremaining=&columns-t:txb.size[tcol]+loff
					let NextCol=(tcol+1)%len(t:txb.name)
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bot '.(spaceremaining-1).'vsp '.escape(t:txb.name[NextCol],' ')
						exe alignmentcmd
						exe t:txb.exe[NextCol]
						norm! 0
						let spaceremaining-=t:txb.size[NextCol]+1
						let NextCol=(NextCol+1)%len(t:txb.name)
					endwhile
					se scrollopt=ver,jump
					windo se wfw
				en
				let c_wn=bufwinnr(c_bf)
				if c_wn!=-1
					exe c_wn.'winc w'
					exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
				else
					norm! 0g$
				en
			en
		en
		return -extrashift
	elseif a:N>0
		let tcol=t:txb.ix[bufname(winbufnr(1))]
		let [bcol,loff,extrashift,N]=[t:txb.ix[bufname(winbufnr(winnr('$')))],winwidth(1)==&columns? (&wrap? (t:txb.size[tcol]>&columns? t:txb.size[tcol]-&columns+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0),0,a:N]
		let nobotresize=0
		if N>=&columns
			if winwidth(1)==&columns
				let loff+=&columns
			else
				let loff=winwidth(winnr('$'))
				let bcol=tcol
			en
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%len(t:txb.name)
			en
			let toshift=N-&columns
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%len(t:txb.name)
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%len(t:txb.name)
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%len(t:txb.name)
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%len(t:txb.name)
				let loff=0
			else
				let loff+=toshift	
			en
			se scrollopt=jump
			exe 'e '.escape(t:txb.name[tcol],' ')
			exe alignmentcmd
			exe t:txb.exe[tcol]
			se scrollopt=ver,jump
			only
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			if winwidth(1)==1
				let c_wn=winnr()
				wincmd t
				hide
				let N-=2
				if N<=0
					if c_wn!=1
						exe (c_wn-1).'winc w'
					else
						1winc w
						norm! 0
					en
					return
				en
			en
			let shifted=0
			while winwidth(1)<=N
				let w2=winwidth(2)
				let extrashift=winwidth(1)==N
				let shifted+=winwidth(1)+1
				wincmd t
				hide
				if winwidth(1)==w2
					let nobotresize=1
				en
				let tcol=(tcol+1)%len(t:txb.name)
				let loff=0
			endw
			let N+=extrashift
			let loff+=N-shifted
		en
		let wf=winwidth(1)-N
		if wf+N!=&columns
			if !nobotresize
				wincmd b
				exe 'vert res+'.N
				if virtcol('.')!=wincol()
					norm! 0
				en
				wincmd t	
				if winwidth(1)!=wf
					exe 'vert res'.wf
				en
			en
			while winwidth(winnr('$'))>=t:txb.size[bcol]+2
				wincmd b
				se nowfw scrollopt=jump
				let nextcol=(bcol+1)%len(t:txb.name)
				exe 'rightb vert '.(winwidth(0)-t:txb.size[bcol]-1).'split '.escape(t:txb.name[nextcol],' ')
				exe alignmentcmd
				exe t:txb.exe[nextcol]
				wincmd h
				se wfw
				wincmd b
				norm! 0
				let bcol=nextcol
				se scrollopt=ver,jump
			endwhile
			wincmd t
			let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
			exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				exe c_vc>=winwidth(0)? 'norm! 0g$' : 'norm! '.c_vc.'|'
			else
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		elseif &columns-t:txb.size[tcol]+loff>=2
			let bcol=tcol
			let spaceremaining=&columns-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let bcol=(bcol+1)%len(t:txb.name)
				exe 'bot '.(spaceremaining-1).'vsp '.escape(t:txb.name[bcol],' ')
				exe alignmentcmd
				exe t:txb.exe[bcol]
				norm! 0
				let spaceremaining-=t:txb.size[bcol]+1
			endwhile
			se scrollopt=ver,jump
			windo se wfw
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				winc t
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				if c_vc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.c_vc.'|'
				en
			else
				winc t
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		else
			let offset=loff-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let c_wn=bufwinnr(c_bf)
			if c_wn==-1
				norm! g0
			elseif c_wn!=1
				exe c_wn.'winc w'
				if c_vc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.c_vc.'|'
				en
			else
				exe (c_vc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.c_vc.'|')
			en
		en
		return extrashift
	en
endfun
