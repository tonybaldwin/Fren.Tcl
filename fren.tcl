#! /usr/bin/env wish8.5

##############################################
# fren.Tcl - friendica+statusnet posting client thingy 
# (c) tony baldwin : http://tonybaldwin.me
# friendica profile : http://free-haven.org/profile/tony 
# released according to the terms of the Gnu Public License, v. 3 or later
# further licensing details at the end of the code.

package require http
package require base64

uplevel #0 [list source ~/frentcl.conf]

#############################
# I've been told that there are better ways to get stuff done
# than using tonso global variables.
# nonetheless, I'm about to name a whole herd of global variables:


global uname
global pwrd
global filename
global brow
global post
global url
global surl
global sname
global swrd
global sn
global fb
global twit
global tm
global ps
global dw
global lj
global wp
global subject

set subject "posted with fren.tcl"
set sn 0
set fb 0
set twit 0

set allvars [list brow uname pwrd url sname swrd surl novar]

set year [clock format [clock second] -format %Y]
set mon [clock format [clock seconds] -format %m]
set day [clock format [clock seconds] -format %d]
set hour [clock format [clock seconds] -format %H]
set min [clock format [clock seconds] -format %M]

set tagsc "0"
set filename " "
set currentfile " "
set wrap word


font create font  -family fixed

set novar "cows"

set file_types {
{"All Files" * }
{"fposts" {.fpost}}
{"html, xml" {.html .HTML .xml .XML}}
{"Text Files" { .txt .TXT}}
}

############33
# keybindings

bind . <Escape> leave
bind . <Control-z> {catch {.txt.txt edit undo}}
bind . <Control-r> {catch {.txt.txt edit redo}}
bind . <Control-a> {.txt.txt tag add sel 1.0 end}
bind . <F3> {FindPopup}
bind . <Control-s> {file_save}
bind . <Control-b> {file_saveas}
bind . <Control-o> {OpenFile}
bind . <Control-q> {clear}
bind . <F8> {prefs}
bind . <F7> {browz}
bind . <F5> {wordcount}
bind . <Control-Return> {postup}

tk_setPalette background #78b3d2 foreground #000000

wm title . "FrenTcl - friendica Composition Tool"

######3
# Menus
#################################

# menu bar buttons
frame .fluff -bd 1 -relief raised

tk::menubutton .fluff.mb -text File -menu .fluff.mb.f 
tk::menubutton .fluff.ed -text Edit -menu .fluff.ed.t 
tk::menubutton .fluff.ins -text Insert -menu .fluff.ins.t 
tk::menubutton .fluff.view -text View -menu .fluff.view.t
tk::label .fluff.font1 -text "Font size:" 
ttk::combobox .fluff.size -width 4 -value [list 8 10 12 14 16 18 20 22] -state readonly

bind .fluff.size <<ComboboxSelected>> [list sizeFont .txt.txt .fluff.size]

# file menu
#############################
menu .fluff.mb.f -tearoff 1
.fluff.mb.f add command -label "Open" -command {OpenFile} -accelerator Ctrl+o
.fluff.mb.f add command -label  "Save" -command {file_save} -accelerator Ctrl+s
.fluff.mb.f  add command -label "SaveAs" -command {file_saveas} -accelerator Ctrl-b
.fluff.mb.f add command -label "Clear" -command {clear} -accelerator Ctrl+q
.fluff.mb.f add separator
.fluff.mb.f  add command -label "Quit" -command {leave} -accelerator Escape


# edit menu
######################################3
menu .fluff.ed.t -tearoff 1
.fluff.ed.t add command -label "Cut" -command cut_text -accelerator Ctrl+x
.fluff.ed.t add command -label "Copy" -command copy_text -accelerator Ctrl+c
.fluff.ed.t add command -label "Paste" -command paste_text -accelerator Ctrl+v
.fluff.ed.t add command -label "Select all"	-command ".txt.txt tag add sel 1.0 end" -accelerator Ctrl+a
.fluff.ed.t add command -label "Undo" -command {catch {.txt.txt edit undo}} -accelerator Ctrl+z
.fluff.ed.t add command -label "Redo" -command {catch {.txt.txt edit redo}} -accelerator Ctrl+r
.fluff.ed.t add separator
.fluff.ed.t add command -label "Search/Replace" -command {FindPopup} -accelerator F3
.fluff.ed.t add command -label "convert <tags>" -command {fixtags}
.fluff.ed.t add separator
.fluff.ed.t add command -label "Word Count" -command {wordcount} -accelerator F5
.fluff.ed.t add separator
.fluff.ed.t add command -label "Preferences" -command {prefs} -accelerator F8


tk::button .fluff.help -text "Help" -command {help}
tk::button .fluff.abt -text "About" -command {about}


# inserts menu
###########################3
menu .fluff.ins.t -tearoff 1
.fluff.ins.t add command -label "Link" -command {linkin}
.fluff.ins.t add command -label "Image" -command {bimg}
.fluff.ins.t add command -label "E-mail" -command {bmail}
.fluff.ins.t add command -label "friendica" -command {bfren}
.fluff.ins.t add command -label "Youtube" -command {ytube}
.fluff.ins.t add command -label "BlockQuote" -command {bquote}
.fluff.ins.t add command -label "CodeBlock" -command {bcode}
.fluff.ins.t add command -label "Time Stamp" -command {indate}



# view menu
####################################
menu .fluff.view.t -tearoff 1

.fluff.view.t add command -label "friendica" -command {
    exec $::brow "$::url" &
    }
    
.fluff.view.t add command -label "StatusNet" -command {
    exec $::brow "$::surl" &
}

tk::label .fluff.tit -text " Subject or Title: "
tk::entry .fluff.titi -textvariable subject

# pack em in...
############################

pack .fluff.mb -in .fluff -side left
pack .fluff.ed -in .fluff -side left
pack .fluff.ins -in .fluff -side left
pack .fluff.view -in .fluff -side left
pack .fluff.font1 -in .fluff -side left
pack .fluff.size -in .fluff -side left

pack .fluff.tit -in .fluff -side left
pack .fluff.titi -in .fluff -side left

pack .fluff.help -in .fluff -side right
pack .fluff.abt -in .fluff -side right

pack .fluff -in . -fill x

# xposting ...
###############

frame .flu -bd 1 -relief raised

tk::label .flu.lbl -text "Xpost to "
tk::label .flu.st -text "Status "
tk::checkbutton .flu.stx -variable sn
tk::label .flu.tw -text "Tweet "
tk::checkbutton .flu.twx -variable twit
tk::label .flu.fb -text "FB "
tk::checkbutton .flu.fbx -variable fb
tk::label .flu.lj -text "LJ "
tk::checkbutton .flu.ljx -variable lj
tk::label .flu.dw -text "DW "
tk::checkbutton .flu.dwx -variable dw
tk::label .flu.pos -text "Posterous "
tk::checkbutton .flu.ptx -variable ps
tk::label .flu.tum -text "Tumblr " 
tk::checkbutton .flu.tmb -variable tm
tk::label .flu.wpp -text "WP "
tk::checkbutton .flu.wpx -variable wp
tk::button .flu.post -text "POST" -command {postup}

pack .flu.lbl -in .flu -side left
pack .flu.lj -in .flu -side left
pack .flu.ljx -in .flu -side left
pack .flu.dw -in .flu -side left
pack .flu.dwx -in .flu -side left
pack .flu.pos -in .flu -side left
pack .flu.ptx -in .flu -side left
pack .flu.tum -in .flu -side left
pack .flu.tmb -in .flu -side left
pack .flu.wpp -in .flu -side left
pack .flu.wpx -in .flu -side left
pack .flu.tw -in .flu -side left
pack .flu.twx -in .flu -side left
pack .flu.fb -in .flu -side left
pack .flu.fbx -in .flu -side left
pack .flu.st -in .flu -side left
pack .flu.stx -in .flu -side left
pack .flu.post -in .flu -side right

pack .flu -in . -fill x



# Here is the text widget
########################################TEXT WIDGET
# amazingly simple, this part, considering the great power in this little widget...
# of course, that's because someone a lot smarter than me built the widget already.
# that sure was nice of them...

frame .txt -bd 2 -relief sunken
text .txt.txt -yscrollcommand ".txt.ys set" -xscrollcommand ".txt.xs set" -maxundo 0 -undo true -wrap word -bg #fffdc0 -fg #000000

scrollbar .txt.ys -command ".txt.txt yview"
scrollbar .txt.xs -command ".txt.txt xview" -orient horizontal

pack .txt.xs -in .txt -side bottom -fill x
pack .txt.txt -in .txt -side left -fill both -expand true

pack .txt.ys -in .txt -side left -fill y
pack .txt -in . -fill both -expand true

focus .txt.txt
set foco .txt.txt
bind .txt.txt <FocusIn> {set foco .txt.txt}


#  statusnet
###########################################
frame .dt

grid [tk::label .dt.ol -text "StatusNet:"]\
[tk::entry .dt.ent -width 70 -textvariable udate]\
[tk::button .dt.dt -text "Update" -command "dent"]\
[tk::button .dt.qt -text "Quit" -command {exit}]
pack .dt -in . -fill x

###
# font size, affects size of font in editor, not in post
# to affect font in post, you have to use html tags...sorry
# I should built that in.
########################################################

proc sizeFont {txt combo} {
	set font [$txt cget -font]
	font configure $font -size [list [$combo get]]
}


###
# open
############################

proc OpenFile {} {

if {$::filename != " "} {
	eval exec tcltext &
	} else {
	global filename
	set filename [tk_getOpenFile -filetypes $::file_types]
	wm title . "Now Tickling: $::filename"
	set data [open $::filename RDWR]
	.txt.txt delete 1.0 end
	while {![eof $data]} {
		.txt.txt insert end [read $data 1000]
		}
	close $data
	.txt.txt mark set insert 1.0
	}
}

##
# save & save-as
###########################

proc file_save {} {
	if {$::filename != " "} {
   set data [.txt.txt get 1.0 {end -1c}]
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
	} else {file_saveas}
 
}

proc file_saveas {} { 
global filename
set filename [tk_getSaveFile -filetypes $::file_types]
   set data [.txt.txt get 1.0 {end -1c}]
   wm title . "Now Tickling: $::filename"
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
}

# about message box
####################################ABOUT
# it's a bloody message box...
# are you seriously trying to read this code?
# Does you head hurt yet?

proc about {} {

toplevel .about
wm title .about "About FrenTcl"
# tk_setPalette background $::wbg 

tk::message .about.t -text "FrenTcl\n by Tony Baldwin\n tony@free-haven.org\n A friendica post composition client written in tcl/tk\n Released under the GPL\n For more info see README, or\n http://tonyb.us/frentcl\n" -width 280
tk::button .about.o -text "Okay" -command {destroy .about} 
pack .about.t -in .about -side top
pack .about.o -in .about -side top

}

# find/replace/go to line
############################################FIND REPLACE DIALOG

proc FindPopup {} {

global seltxt repltxt

toplevel .fpop 

# -width 12c -height 4c

wm title .fpop "Find Stuff... (but not your socks)"

frame .fpop.l1 -bd 2 -relief raised

tk::label .fpop.l1.fidis -text "FIND     :"
tk::entry .fpop.l1.en1 -width 20 -textvariable seltxt
tk::button .fpop.l1.finfo -text "Forward" -command {FindWord  -forwards $seltxt}
tk::button .fpop.l1.finbk -text "Backward" -command {FindWord  -backwards $seltxt}
tk::button .fpop.l1.tagall -text "Highlight All" -command {TagAll}

pack .fpop.l1.fidis -in .fpop.l1 -side left
pack .fpop.l1.en1 -in .fpop.l1 -side left
pack .fpop.l1.finfo -in .fpop.l1 -side left
pack .fpop.l1.finbk -in .fpop.l1 -side left
pack .fpop.l1.tagall -in .fpop.l1 -side left
pack .fpop.l1 -in .fpop -fill x


frame .fpop.l2 -bd 2 -relief raised

tk::label .fpop.l2.redis -text "REPLACE:"
tk::entry .fpop.l2.en2 -width 20 -textvariable repltxt
tk::button .fpop.l2.refo -text "Forward" -command {ReplaceSelection -forwards}
tk::button .fpop.l2.reback -text "Backward" -command {ReplaceSelection -backwards}
tk::button .fpop.l2.repall -text "Replace All" -command {ReplaceAll}

pack .fpop.l2.redis -in .fpop.l2 -side left
pack .fpop.l2.en2 -in .fpop.l2 -side left
pack .fpop.l2.refo -in .fpop.l2 -side left
pack .fpop.l2.reback -in .fpop.l2 -side left
pack .fpop.l2.repall -in .fpop.l2 -side left
pack .fpop.l2 -in .fpop -fill x

frame .fpop.l3 -bd 2 -relief raised

tk::label .fpop.l3.goto -text "Line No. :"
tk::entry .fpop.l3.line -textvariable lino
tk::button .fpop.l3.now -text "Go" -command {gotoline}
tk::button .fpop.l3.dismis -text Done -command {destroy .fpop}

pack .fpop.l3.goto -in .fpop.l3 -side left
pack .fpop.l3.line -in .fpop.l3 -side left
pack .fpop.l3.now -in .fpop.l3 -side left
pack .fpop.l3.dismis -in .fpop.l3 -side right
pack .fpop.l3 -in .fpop -fill x


# focus .fpop.en1
}
########################FIND/REPLACE#########
## all this find-replace stuff needs work...
#############################################

proc FindWord {swit seltxt} {
global found
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
scan [.txt.txt index insert] %d cl
if {[string compare $swit "-forwards"] == 0 } {
set curpos [.txt.txt index "insert + $l1 chars"]

for {set i $cl} {$i < $nl} {incr i} {
		
	#.txt.txt mark set first $i.0
	.txt.txt mark set last  $i.end ;#another way "first lineend"
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search $swit -exact $seltxt $curpos]
	if {$curpos != ""} {
		selection clear .txt.txt 
		.txt.txt mark set insert "$curpos + $l1 chars "
		.txt.txt see $curpos
		set found 1
		break
		} else {
		set curpos $lpos
		set found 0
			}
	}
} else {
	set curpos [.txt.txt index insert]
	set i $cl
	.txt.txt mark set first $i.0
	while  {$i >= 1} {
		
		set fpos [.txt.txt index first]
		set i [expr $i-1]
		
		set curpos [.txt.txt search $swit -exact $seltxt $curpos $fpos]
		if {$curpos != ""} {
			selection clear .txt.txt
			.txt.txt mark set insert $curpos
			.txt.txt see $curpos
			set found 1
			break
			} else {
				.txt.txt mark set first $i.0
				.txt.txt mark set last "first lineend"
				set curpos [.txt.txt index last]
				set found 0
			}
		
	}
}
}

proc FindSelection {swit} {

global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
FindWord $swit $seltxt
}

proc FindValue {} {

FindPopup
}

proc TagSelection {} {
global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
TagAll 
}

proc ReplaceSelection {swit} {
global repltxt seltxt found
set l1 [string length $seltxt]
FindWord $swit $seltxt
if {$found == 1} {
	.txt.txt delete insert "insert + $l1 chars"
	.txt.txt insert insert $repltxt
	}
}

proc ReplaceAll {} {
global seltxt repltxt
set l1 [string length $seltxt]
set l2 [string length $repltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index 1.0]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
	
	if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		.txt.txt delete insert "insert + $l1 chars"
		.txt.txt insert insert $repltxt
		.txt.txt mark set insert "insert + $l2 chars"
		set curpos [.txt.txt index insert]
		} else {
			set curpos $lpos
			}
	}
}

proc TagAll {} {
global seltxt 
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index insert]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
		if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		scan [.txt.txt index "insert + $l1 chars"] %f pos
		.txt.txt tag add $seltxt $curpos $pos
		.txt.txt tag configure $seltxt -background yellow -foreground purple
		.txt.txt mark set insert "insert + $l1 chars"
		set curpos $pos
		} else {
			set curpos $lpos
			}
	}
}

# Procedure for finding correct text or entry widget
########################################################33

proc findwin {char} {
	global foco
	set winclass [winfo class $foco]
	$foco insert insert $char
	if {$winclass == "Text"} {
		$foco edit separator
		}
	after 10 {focus $foco}
}


## go to line number 

proc gotoline {} {
	set newlineno [.fpop.l3.line get]
	.txt.txt mark set insert $newlineno.0
	.txt.txt see insert
	focus .txt.txt
	set foco .txt.txt
}


## show word count

proc wordcount {} {
	set wordsnow [.txt.txt get 1.0 {end -1c}]
	set wordlist [split $wordsnow]
	set countnow 0
	foreach item $wordlist {
		if {$item ne ""} {
			incr countnow
		}
	}
	toplevel .count
	wm title .count "Word Count"
	tk::label .count.word -text "Current count:"
	tk::label .count.show -text "$countnow words"
	tk::button .count.ok -text "Okay" -command {destroy .count}
	
	pack .count.word -in .count -side top
	pack .count.show -in .count -side top
	pack .count.ok -in .count -side top
}

#############################################
# insertions menu commands

## insert time stamp

proc indate {} {
	if {![info exists date]} {set date " "}
	set date [clock format [clock seconds] -format "%R %p %D"]
	.txt.txt insert insert $date
}


# some html tags
# or really, bbcode tags
# to be inserted in the post.
###################################
proc linkin {} {

toplevel .link
wm title .link "Insert Hyperlink"

frame .link.s
grid [tk::label .link.s.l1 -text "URL:"]\
[tk::entry .link.s.e1 -width 40 -textvariable inurl]
grid [tk::label .link.s.l2 -text "Link text:"]\
[tk::entry .link.s.e2 -width 40 -textvariable ltxt]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[url=$inurl\]$ltxt\[/url\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}

proc bcode {} {
.txt.txt insert insert "\[code\]INSERT CODE TEXT HERE\[/code\]"
}

proc ytube {} {
.txt.txt insert insert "\[youtube\]INSERT VIDEO URL HERE\[/youtube\]"
}

proc bquote {} {
.txt.txt insert insert "\[quote\]INSERT QUOTED TEXT HERE\[/quote\]"
}

proc bimg {} {

toplevel .link
wm title .link "Insert Image"

frame .link.s
grid [tk::label .link.s.l1 -text "IMG URL:"]\
[tk::entry .link.s.e1 -width 40 -textvariable imurl]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[img\]$imurl\[/img\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}

proc bmail {} {

toplevel .link
wm title .link "Insert E-mail"

frame .link.s
grid [tk::label .link.s.l1 -text "E-mail address:"]\
[tk::entry .link.s.e1 -width 40 -textvariable eml]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[mail\]$eml\[/mail\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}


proc bfren {} {
.txt.txt insert insert "~friendica"
}

# b'bye (quit procedure)
##################################

proc leave {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
		{file_save} 
		{exit}
				}
	if {$xanswer eq "no"} {exit}
		} else {exit}
}


## clear text widget / close document
#########################################

proc clear {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
	{file_save} 
	{yclear}
		}
	if {$xanswer eq "no"} {yclear}
	}
}

proc yclear {} {
	.txt.txt delete 1.0 end
	.txt.txt edit reset
	.txt.txt edit modified 0
	set ::filename " "
	wm title . "FrenTcl"
}

# open friendica in browser
###########################################

proc browz {url} {
	if {[string length $::brow] != 0} {
	eval exec $::brow $url &
	} else {
	tk_messageBox -message "You have not chosen a browser.\nLet's set the browser now." -type ok -title "Set browser"
	set ::brow [tk_getOpenFile -filetypes $::file_types]
	exec	$::brow $url
	}
}


proc sapro {} {
	set novar "cows"
	set header "#!/usr/bin/env wish8.5 "
   	set filename frentcl.conf
   	set fileid [open $filename w]
   	puts $fileid $header
   	foreach var $::allvars {puts $fileid [list set $var [set ::$var]]}
   	close $fileid
   	
   	 tk_messageBox -message "Preferences saved" 
} 

proc setbro {} {
set filetypes " "
set ::brow [tk_getOpenFile -filetypes $filetypes -initialdir "/usr/bin"]
}

proc fixtags {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	"\"" "%22"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
	} else {
	if { $::tagsc eq 1 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"&lt;" "<" 
	"&gt;" ">" 
	"&amp;" "&" 
	"%22" "\""
	} $content]
	set ::tagsc "0"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
	}
   }
}

######################
#  global preferences


proc prefs {} {

toplevel .pref

wm title .pref "FrenTcl preferences"

grid [tk::label .pref.b1o -text "friendica:"]

grid [tk::label .pref.b1n -text "Server:"]\
[tk::entry .pref.b1nm -text url]\
[tk::label .pref.b1un -text "Username:"]\
[tk::entry .pref.b1nome -textvariable uname]\
[tk::label .pref.b1p -text "password:"]\
[tk::entry .pref.b1pw -show * -textvariable pwrd]

grid [tk::label .pref.b2o -text "StatusNet:"]

grid [tk::label .pref.b2n -text "Server:"]\
[tk::entry .pref.b2nm -text surl]\
[tk::label .pref.b2un -text "Username:"]\
[tk::entry .pref.b2nome -textvariable sname]\
[tk::label .pref.b2p -text "password:"]\
[tk::entry .pref.b2pw -show * -textvariable swrd]

grid [tk::button .pref.bro -text "Browser" -command {setbro}]\
[tk::entry .pref.br0z -textvariable brow]\
[tk::button .pref.sv -text "Save" -command sapro]\
[tk::button .pref.ok -text "Close" -command {destroy .pref}]


}

################
# post to friendica

proc postup {} {
    
set ptext [.txt.txt get 1.0 {end -1c}]
	set auth "$::uname:$::pwrd"
	set auth64 [::base64::encode $auth]
	set myquery [::http::formatQuery "status" "$ptext" "title" $::subject" "statusnet_enable" "$::sn" "twitter_enable" "$::twit"  "facebook_enable" "$::fb" "wppost_enable" "$::wp" "ljpost_enable" "$::lj" "dwpost_enable" "$::dw" "tumblr_enable" "$::tm" "posterous_enable" "$::ps" "source" "fren.tcl"]
	set myauth [list "Authorization" "Basic $auth64"]
	set token [::http::geturl $::url/api/statuses/update.xml -headers $myauth -query $myquery]
	
}


# status updates to status net
##################################
proc dent {} {
	set auth "$::sname:$::swrd"
	set auth64 [::base64::encode $auth]
	if { [string length $::udate] > 140 } {
		toplevel .babbler 
		wm title .babbler "You talk too much!"
		tk::message .babbler.msg -text "Your update is too long.\nIt can only have 140 characters,\nthere, smarty pants." -width 270
		tk::button .babbler.btn -text "Okay" -command {destroy .babbler} 
		pack .babbler.msg -in .babbler -side top
		pack .babbler.btn -in .babbler -side top
		} else {
		set myquery [::http::formatQuery "status" "$::udate" "source" "fren.tcl"]
		set myauth [list "Authorization" "Basic $auth64"]
		# puts "http::geturl $::serv -headers $myauth -query $myquery"
		set token [::http::geturl $::surl/api/statuses/update.xml -headers $myauth -query $myquery]
		}
}

#####################################
# Help dialog
proc help {} {
toplevel .help
wm title .help "OMFG HELP!!!"

frame .help.bt
grid [tk::button .help.bt.vt -text "RTFM" -command {browz http://tonybaldwin.me/hax/doku.php?id=frentcl}]\
[tk::button .help.bt.out -text "Close" -command {destroy .help}]

frame .help.t

text .help.t.inf -width 80 -height 10
.help.t.inf insert end "FrenTcl, a FREE and ticklish friendica posting client.\nThere is a manual and further info at http://tonyb.us/frentcl\nClicking the RTFM button above will open the manual in your browser.\n\nTony Baldwin - http://tonybaldwin.me\nhttp://free-haven.org/profile/tony"

pack .help.bt -in .help -side top
pack .help.t -in .help -side top
pack .help.t.inf -in .help.t -fill x

}

#############################################################################
# This program was written by Anthony Baldwin / http://tonybaldwin.me/
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#########
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#########
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
############################################################################
