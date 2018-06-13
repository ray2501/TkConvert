#!/usr/bin/env tclsh

#
# A simple Chinese Convert program written by Tcl/Tk, version 0.1
# OpenCC requires >= 1.0.1
#

package require Tk
package require opencc

ttk::setTheme "default"

ttk::frame .menubar -relief raised -borderwidth 2
pack .menubar -side top -fill x

ttk::menubutton .menubar.file -text File -menu .menubar.file.menu
menu .menubar.file.menu -tearoff 0
.menubar.file.menu add command -label Quit -command exit
ttk::menubutton .menubar.help -text Help -menu .menubar.help.menu
menu .menubar.help.menu -tearoff 0
.menubar.help.menu add command -label About -command HelpAbout
pack .menubar.file .menubar.help -side left

# Contextual Menus
menu .menu
foreach i [list Copy Exit] {
    .menu add command -label $i -command $i
}

if {[tk windowingsystem]=="aqua"} {
    bind . <2> "tk_popup .menu %X %Y"
    bind . <Control-1> "tk_popup .menu %X %Y"
} else {
    bind . <3> "tk_popup .menu %X %Y"
}

ttk::radiobutton .s2t -text "Simplified Chinese to Traditional Chinese" -variable config -value s2t
ttk::radiobutton .t2s -text "Traditional Chinese to Simplified Chinese" -variable config -value t2s
ttk::radiobutton .s2tw -text "Simplified Chinese to Traditional Chinese (Taiwan Standard)" \
    -variable config -value s2tw
ttk::radiobutton .tw2s -text "Traditional Chinese (Taiwan Standard) to Simplified Chinese" \
    -variable config -value tw2s
ttk::radiobutton .s2hk -text "Simplified Chinese to Traditional Chinese (Hong Kong Standard)" \
    -variable config -value s2hk
ttk::radiobutton .hk2s -text "Traditional Chinese (Hong Kong Standard) to Simplified Chinese" \
    -variable config -value hk2s
ttk::radiobutton .s2twp -text "Simplified Chinese to Traditional Chinese (Taiwan Standard) with Taiwanese idiom" \
    -variable config -value s2twp
ttk::radiobutton .tw2sp -text "Traditional Chinese (Taiwan Standard) to Simplified Chinese with Mainland Chinese idiom" \
    -variable config -value tw2sp
ttk::radiobutton .t2tw -text "Traditional Chinese (OpenCC Standard) to Taiwan Standard" \
    -variable config -value t2tw
ttk::radiobutton .t2hk -text "Traditional Chinese (OpenCC Standard) to Hong Kong Standard" \
    -variable config -value t2hk

pack .s2t -side top -anchor nw
pack .t2s -side top -anchor nw
pack .s2tw -side top -anchor nw
pack .tw2s -side top -anchor nw
pack .s2hk -side top -anchor nw
pack .hk2s -side top -anchor nw
pack .s2twp -side top -anchor nw
pack .tw2sp -side top -anchor nw
pack .t2tw -side top -anchor nw
pack .t2hk -side top -anchor nw

text .t -height 12 -width 72 -background white -font {"Noto Sans" -14}
pack .t

text .t2 -height 12 -width 72 -background white -font {"Noto Sans" -14} -state disabled
pack .t2

ttk::button .doit -text "Run" -command DoIt
pack .doit -side right

# Handle F1
bind all <F1> HelpAbout

#=================================================================
# Event Handler
#=================================================================

proc Copy {} {
    clipboard clear
    set t2text [.t2 get 0.0 end]
    if {[string length $t2text] > 0} {
        clipboard append -format UTF8_STRING -- $t2text
    }
}

proc Exit {} {
    set answer [tk_messageBox -message "Really quit?" -type yesno -icon warning]
    switch -- $answer {
        yes exit
    }
}

proc DoIt {} {
    if {[info exists ::config]==0} {
        set ::config t2s
    }

    set oldtext [.t get 0.0 end]
    if {[string length $oldtext] > 0} {
       if {[catch {opencc handle "$::config.json"}]==1} {
           puts "opencc handle open failed."
           return
       }
    
       set newtext [handle convert $oldtext]
       handle close
       .t2 configure -state normal
       .t2 delete 0.0 end
       .t2 insert end $newtext 
       .t2 configure -state disabled
    }	    

}

proc HelpAbout {} {
    set ans [tk_messageBox -title "About" -type ok -message \
	"Power by tcl-opencc, version v0.1." ]
}

