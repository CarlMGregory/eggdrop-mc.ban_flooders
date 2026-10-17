##
# Ban Flooders v2.1.3
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug?  http://mc.purehype.net/bugzilla/
##

##
# This script will automatically kick/ban a public/msg/ctcp flooder for x
# minute(s) from all channels there (if bot is op'd).  Flood settings are
# defined by `.chaninfo''s flood setting.  You set the flood settings via
# `.chanset'.
#
# This script excels in takeover (deop flood) prevention (especially if the
# script runs on more than 1 bot and the bot's are linked.
#
# For good flood protection, here are a few pointers:
#   - Tweak your flood settings via `.chanset' just right... if the flood
#     settings are to lenient, the script will do you no good.  The settings are
#     really up to you, different channels require different settings.  I.e.
#     This if my flood-deop, 3:10
#   - Use other scripts as well; mc.banflooders does excel in things like
#     takeover attempt (deop floods).  But other scripts do things this one
#     doesn't.
#     Recommended scripts, and why:
#       o sentinel (by slennox), this script is great for protecting the channel
#         from mass flood attacks.  As mc.banflooders (due to how it feeds from
#         eggdrop's flood-types) only watches floods on a per person basis.
#       o mc.limit (by MC_8), this script will further protection from large
#         floodnets.  It keeps a limit on the channel just above the number of
#         people in the channel and updates it slowly ... making it hard for a
#         large floodnet to join really fast.
#       o repeat (by slennox), this serves 2 purposes;
#         1) Removing those pesky people that repeat.
#         2) Stop large floodnets from doing a repeat floods.
#       o "+bitch", this isn't a script; it's a core function of eggdrop.  You
#         set it via `.chanset'.  This ensures that ONLY registered ops (users
#         added to the bot with +o) get ops, and no one else.
#       o superbitch (by slennox), this is pretty much the same as +bitch, but
#         instead of just deop'n the person that isn't a registered op, it will
#         also deop the person that op'd that non-registered person.  Some say
#         that this is excessive, but I use it and like it.
##

##
# Configuration
##
#

# What flagged users are exempt from this script?  Set to "" to exempt no-one.
# Flag syntax: <global>|<channel>
set mc_bf(exempt) ""

# [0=no/1=yes] Do you want to exempt op'd users?
set mc_bf(exempt:op) 0

# [0=no/1=yes] Do you want to exempt voice'd users?
set mc_bf(exempt:voice) 0

# If a user is found flooding, how long (in min.s) do you want to ban the user?
#   -2 = Permanent ban (no expiration in bot records).
#   -1 = Will not ban (no ban, disable banning).
#    0 = Performs a server ban, but doesn't store the ban in the bot's banlist.
#   Any number greater than 0 will be the time in which the ban will expire.
#   All ban's will be channel ban's, if you want it to be global then put a '@'
#   in front of the time.
#     Example: set mc_bf(bantime) @1400
#   Also, if you want the ban to be 'sticky' (read '.help stick' in the bot's
#   dcc console), then append the time with a '!'.
#     Example: set mc_bf(bantime) 1400!
#     Example: set mc_bf(bantime) @1400!
set mc_bf(bantime) "@43200"


# What do you want the ban message to be?
# Replacment variables are:
#  %nick = IRC Nickname of the flooder.
#  %ident = Ident of the flooder.
#  %host  = Host of the flooder.
#  %hand  = Handle of the flooder.
#  %chan  = Channel where the flood happened (or "me" if personal flood).
#  %type  = What type of flood (ctcp/ pub/ msg/ join).
set mc_bf(banmsg) "Not smart to %type flood %chan."

# [0=no/1=yes] If a deop flood is detected, do you want the bot to try and de
# synch it's self (-o+o self self)?  This is good to ensure that all the linked
# irc servers know that the bot is an op.  Please note that some IRC servers
# such as EfNet will not process this correctly and in doing so, the bot will
# loose it's ops.  This feature does work on Undernet.
set mc_bf(desynch) 1

# [0=no/1=yes] If a deop flood is detected, do you want to set the channel to
# +simk?  The key will be a random key.
set mc_bf(deop:enforce:chmod) 1

# How long do you want to limit the key to.  Before this was set to 24 and could
# not be changed, but I found that undernet has a bug that allows 24 but only
# lets you unset at 23 (so keys could not be removed).  If your on undernet, I
# suggest you set this to 23.  Any other network, I do not know -- do a long +k
# in your channel then remove it to see what your length limit is.
set mc_bf(key:limit) 23

# If a deop flood is detected and the above, deop:enforce:chmod, is enabled; how
# long (in sec.s) do you want to wait before unlocking the channel?  Assuming
# the bot has recovered ops by that time.  Set this to 0 if you want don't want
# the bot to unlock the channel.
set mc_bf(deop:enforce:time) 15

# [0=no/1=yes] If a deop flood is detected, do you want to have this script to
# deop all non registered ops (not +o in userfile)?
set mc_bf(bitch) 1

# [0=no/1=yes] If a deop flood is detected, do you want to utilize the botnet?
# If other bots using this script are op'd and are setup to receive these
# requests, it could greatly improve your possibility of recovering from a
# takeover attempt.  Ideal example, 2 bots, 1 is lagged by a couple of seconds
# therefor doesn't see the deop flood yet, so it can properly kick/ban/reop
# effectively.
set mc_bf(deop:bottx) 1

# [0=no/1=yes] Do you want to receive botnet help requests?  Read the above
# setting, deop:bottx, for a better explanation.
set mc_bf(deop:botrx) 1

# If a public flood is detected, what mode change do you want to perform on the
# channel?  Set this to "" to disable.
set mc_bf(pub:enforce:chmod) "+mi"

# If a public flood is detected and the above, pub:enforce:chmod, is enabled;
# how long (in sec.s) do you want to wait before removing the mode change?  Set
# this to 0 if you want don't want the bot to remove the mode change.
set mc_bf(pub:enforce:time) 15

# [0=no/1=yes] If any flood is detected, do you want this script to 'boot' the
# user from the botnet's partyline (if found)?
set mc_bf(boot) 1

# How do you want to mask how the flooders get banned?
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9.
#     But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain with
#                  a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacements as does hostname.
set mc_bf(bantype) 2


## SVS Client (Script Version Service) v3.1.1 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  This will only notify
# users of the new version via a note.  It's up to the owner of the bot to
# download, adjust settings then install the script.

# If a newer version is found, whom do you want to notify?  The notification is
# sent via a note.  Seperate each user with a space, or set this to "" to
# disable SVS notification.  For those whom know TCL; do not put this in list
# format, keep it in string format.
set mc_bf(svs:notify) "MC_8"

# Would you like to restrict the concept of a new version to stable releases
# only?
#   0 = No, inform of both stable and beta release versions.
#   1 = Yes, inform of only stable release versions.
set mc_bf(svs:mode) 0

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##

#Script:mc_bf

set mc_bf(script)      "Ban Flooders"
set mc_bf(version)     "v2.1.3"
set mc_bf(svs:script)  "banflooders"
set mc_bf(svs:version) "002001003000"
set mc_bf(svs:server)  "mc.svs.purehype.net"
set mc_bf(svs:port)    "81"
set mc_bf(svs:get)     "/index.tcl"
set mc_bf(svs:query)   "svs=$mc_bf(svs:script)&version=$mc_bf(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
  set temp(tag) "$mc_bf(script) $mc_bf(version)"
  putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
  putlog "$temp(tag)  will not work with eggdrop $version."
  putlog "$temp(tag)  not loaded."
  return 1
}


# Error system, v3.0
proc mc:bf:error {command error arg} {
  global mc_bf version lastbind errorInfo
  putlog "Error in script $mc_bf(script) $mc_bf(version)."
  putlog "    Error System: v3.0"
  putlog "       Last Bind: [expr {[info exists lastbind]?$lastbind:"-NULL-"}]"
  putlog "         Command: $command"
  putlog "       Arguments: $arg"
  putlog "       Error Msg: $error"
  putlog "    Egg. Version: [expr {[info exists version]?$version:"-NULL-"}]"
  putlog "     TCL Version: [info tclversion]"
  putlog "  TCL Patchlevel: [info patchlevel]"
  putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
  putlog "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
  putlog \
    "*** Please include ALL info. in the bug report, including the next(s)."
  error $errorInfo
}

proc mc:bf:errchk {command arg} {
  if {![catch {eval $command $arg} return]} {return $return}
  mc:bf:error $command $return $arg
  return 0
}
# ^

bind flud - * mc:bf:flud
proc mc:bf:flud {nick uhost hand type chan} {
  return [mc:bf:errchk mc:bf:flud_ [list $nick $uhost $hand $type $chan]]
}
proc mc:bf:flud_ {nick uhost hand type chan} {
  global mc_bf botnick use-silence ignore-time
  if {$mc_bf(exempt) == ""} {set temp() 0} else {set temp() 1}
  if {$chan == "*"} {
    set chan me
    set exempt [expr ([matchattr $hand $mc_bf(exempt)] && $temp())]
  } else {
    set exempt [expr ([matchattr $hand $mc_bf(exempt) $chan] && $temp()) || \
                     ([isop $nick $chan] && $mc_bf(exempt:op)) || \
                     ([isvoice $nick $chan] && $mc_bf(exempt:voice))]
  }; if {$exempt} {return 0}
  putlog "$mc_bf(script):  Detected $nick ($uhost) $type flooding $chan."
  set banmask [mc:bf:maskhostbytype $nick!$uhost $mc_bf(bantype)]
  if {$type == "deop"} {
# Xmit to botnet
    if {$mc_bf(deop:bottx)} {
      set buffer [list [string tolower $nick] deop [string tolower $chan]]
      if {![info exists mc_bf(:buffer:$buffer)]} {
        putallbots [list mc.banflooders $nick $uhost $hand $type $chan $botnick]
        set mc_bf(:buffer:$buffer) [clock seconds]
        # 10 seconds should be enough for botnet lag.
        utimer 10 [list unset mc_bf(:buffer:$buffer)]
      }
    }
# Resynch self
    if {$mc_bf(desynch)} {putquick "MODE $chan -o+o $botnick $botnick" -next}
# Ban and deop flooder
    putquick "MODE $chan -o+b $nick $banmask" -next
# Lock the channel
    if {$mc_bf(deop:enforce:chmod)} {
      set key [encrypt [rand 9999999999] [rand 9999999999]]
      set key [string range $key 0 [expr $mc_bf(key:limit)-1]]
      putquick "MODE $chan +ikms $key" -next
      if {$mc_bf(deop:enforce:time)} {
        set temp() "[list pushmode $chan -i]\; [list pushmode $chan -k $key]\;"
        append temp() " [list pushmode $chan -m]; [list pushmode $chan -s]"
        utimer $mc_bf(deop:enforce:time) $temp()
      }
    }
# Do bitch on channel
    if {$mc_bf(bitch)} {
      foreach user [chanlist $chan -o] {
        if {![isbotnick $user]} {pushmode $chan -o $user}
      }
      flushmode $chan
    }
  } elseif {$type == "pub"} {
    if {$mc_bf(pub:enforce:chmod) != ""} {
      putquick "MODE $chan $mc_bf(pub:enforce:chmod)" -next
      if {$mc_bf(pub:enforce:time)} {
        set temp() \
          [scan "$mc_bf(pub:enforce:chmod)\015" "%s %\[^\015\]" mode end]
        if {$temp() == "1"} {
          set end ""
        }
        if {[regexp -- {\+([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $mode temp() pmode]} {
          set pmode -$pmode
        } else {set pmode ""}
        if {[regexp -- {\-([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $mode temp() nmode]} {
          set nmode +$nmode
        } else {set nmode ""}
        utimer $mc_bf(pub:enforce:time) \
          [list putserv "MODE $chan ${pmode}${nmode} $end"]
      }
    }
  }
  scan $uhost {%[^@]@%s} ident host

  set time $mc_bf(bantime)

  if {[string match *! $time]} {
    set option "sticky"
    set time [string trimright $time !]
  } else {set option "none"}

  if {[string match @* $time]} {
    set global 1
    set time [string trimleft $time @]
  } else {set global 0}

  set reason [mc:bf:replace $mc_bf(banmsg) [list %nick $nick \
                                                 %ident $ident \
                                                 %host $host \
                                                 %hand $hand \
                                                 %chan $chan \
                                                 %type $type]]

  if {$time != "-1"} {
    if {$time == ""} {set time 0}

    if {$chan == "me"} {
      set temp(time) $time
      if {$temp(time) == "-2"} {set temp(time) 0} \
      elseif {$temp(time) == "0"} {set temp(time) ${ignore-time}}
      if {![isignore $banmask]} {
        if {!$temp(time)} {set temp(duration) "permanent"} \
        else {
          # When wrighting, the maximum number [unixtime] can represent is
          # 1999999999.  This may need adjusting if eggdrop decides to go
          # higher.
          set limit [expr (1999999999-[clock seconds])/60] ;# Minutes
          if {$temp(time) > $limit} {
            set temp(1) "Timer number too high"
            set temp(2) "converting; $temp(time) -> $limit"
            putloglev d * "$mc_bf(script): $temp(1), $temp(2)"
            set temp(time) $limit
          }
          set temp(duration) [duration [expr $temp(time)*60]]
        }
        putlog "$mc_bf(script):  Ignoring $nick via $banmask ($temp(duration))."
        newignore $banmask BanFlood $reason $temp(time)
        # Some bot version, forgot which, had a problem with removing the
        # silence after the ignore's time was up.  This is a fix.
        if {([info exists {use-silence}]) &&
            (${use-silence}) &&
            ($temp(time))} {
          timer $temp(time) [list putserv "SILENCE -$banmask"]
        }
      }
    } else {
      set temp(time) $time
      if {$temp(time) == "0"} {
        if {$global} {set temp(channels) [channels]} \
        else {set temp(channels) [list $chan]}
        set temp(lchannels) ""
        foreach temp(channel) $temp(channels) {
          if {[botisop $temp(channel)]} {
            set temp(found) 0
            set temp(banmask) [string tolower $banmask]
            foreach temp(ban) [chanbans $temp(channel)] {
              if {[string tolower $temp(ban)] == $temp(banmask)} {
                set temp(found) 1
                break
              }
            }
            if {!temp(found)} {
              pushmode $temp(channel) +b $banmask
              lappend temp(lchannels) $temp(channel)
            }
          }
        }
        if {[llength $temp(lchannels)]} {
          set temp() "[join $temp(lchannels) ", "] (server ban)"
          putlog "$mc_bf(script):  Banned $nick via $banmask on $temp()."
        }
      } else {
        if {![isban $banmask $chan]} {
          if {$temp(time) == "-2"} {set temp(time) 0}
          if {!$temp(time)} {set temp(duration) "permanent"} \
          else {
            # When wrighting, the maximum number [unixtime] can represent is
            # 1999999999.  This may need adjusting if eggdrop decides to go
            # higher.
            set limit [expr (1999999999-[clock seconds])/60] ;# Minutes
            if {$temp(time) > $limit} {
              set temp(1) "Timer number too high"
              set temp(2) "converting; $temp(time) -> $limit"
              putloglev d * "$mc_bf(script): $temp(1), $temp(2)"
              set temp(time) $limit
            }
            set temp(duration) [duration [expr $temp(time)*60]]
          }
          set temp(1) "Added internal ban to"
          set temp(2) "banlist; $nick via $banmask ($temp(duration))."
          if {$global} {
            newban $banmask BanFlood $reason $temp(time) $option
            putlog "$mc_bf(script):  $temp(1) global $temp(2)"
          } else {
            newchanban $chan $banmask BanFlood $reason $time $option
            putlog "$mc_bf(script):  $temp(1) $chan's $temp(2)"
          }
        }
      }
    }
  }

  if {$mc_bf(boot)} {
    set ban $host
    foreach temp() [whom *] {
      set fhand [lindex $temp() 0]
      set fbot [lindex $temp() 1]
      set fuhost [lindex $temp() 2]
      set fnick [hand2nick $fhand]
      scan $fuhost {%[^@]@%s} fident fhost
      if {[validuser $fhand]} {
        if {$mc_bf(exempt) == ""} {set temp() 0} else {set temp() 1}
        if {$chan == "me"} {
          set exempt [expr ([matchattr $fhand $mc_bf(exempt)] && $temp())]
        } else {
          set exempt [expr ([matchattr $fhand $mc_bf(exempt) $chan] && \
                            $temp()) || \
                           ([isop $fnick $chan] && $mc_bf(exempt:op)) || \
                           ([isvoice $fnick $chan] && $mc_bf(exempt:voice))]
        }
      } else {set exempt 0}
      if {($exempt) ||
          ([string tolower $host] != [string tolower $fhost])} {continue}
      boot $fhand@$fbot $reason
    }
  }; return 1
}

bind bot - mc.banflooders mc:bf:bot
proc mc:bf:bot {from command arg} {
  return [mc:bf:errchk mc:bf:bot_ [list $from $command $arg]]
}
proc mc:bf:bot_ {from command arg} {
  global botnick mc_bf
  set nick [lindex $arg 0]; set uhost [lindex $arg 1]; set hand  [lindex $arg 2]
  set type [lindex $arg 3]; set chan  [lindex $arg 4]; set ifrom [lindex $arg 5]
  set buffer [list [string tolower $nick] [string tolower $type] \
    [string tolower $chan]]
  if {(![validchan $chan]) || (![onchan $botnick $chan]) ||
      ([info exists mc_bf(:buffer:$buffer)])} {return 0}
  set mc_bf(:buffer:$buffer) [clock seconds]
  # 10 seconds should be enough for botnet lag.
  utimer 10 [list unset mc_bf(:buffer:$buffer)]
  if {([onchan $ifrom $chan]) && ($type == "deop") && ($mc_bf(desynch))} {
    putquick "MODE $chan -o+o $ifrom $ifrom" -next
  }
  set temp() "$type flood detected!  Botnet relay"
  append temp() " from $from ($ifrom).  Processing..."
  putlog "$mc_bf(script):  $temp()"
  mc:bf:flud $nick $uhost $hand $type $chan
}

## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# mc:bf:badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:bf:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
  wrong # args: should be "mc:bf:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) ||
      (($llength != "end") && ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# mc:bf:unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:bf:unlist {{args ""}} {
  mc:bf:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# 2list <text>
#     version:
#       v1.0
proc mc:bf:2list {{args ""}} {
  mc:bf:badargs $args 1 1 "text"
  mc:bf:unlist $args text

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# findnicks <nick!ident@host.domain> [channel]
#     version:
#       v2.0
proc mc:bf:findnicks {{args ""}} {
  mc:bf:badargs $args 1 2 "nick!ident@host.domain ?channel?"
  mc:bf:unlist $args hostmask channel

  set hostmask [string tolower $hostmask]

  if {$channel == ""} {set channels [channels]} \
  elseif {![validchan $channel]} {error "no such channel record"} \
  else {set channels [list $channel]}
  set origional_channel $channel

  set list ""
  foreach channel $channels {
    foreach user [chanlist $channel] {
      set nuhost [string tolower $user![getchanhost $user $channel]]
      if {[string match $hostmask $nuhost]} {
        lappend list $user[expr {($origional_channel != "")?"":"@$channel"}]
      }
    }
  }; return $list
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.1
proc mc:bf:maskhostbytype {{args ""}} {
  mc:bf:badargs $args 1 2 "nick!ident@host.domain ?type?"
  mc:bf:unlist $args nuhost type

  set type [expr {($type == "")?5:$type}]
  if {![regexp -- {^1?[0-9]$} $type]} {
    set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
    error "bad type \"$type\": must be [join $valid ", "]"
  }

  # Define the maximum length the ircd allows for an ident.  Standard is 9,
  # however I made it to a variable incase someone wants to change it up.
  set ident_max-length 9

  # Define the maximum length the ircd allows for a hostname/ ip.  Standard is
  # 63, however I made it to a variable incase someone wants to change it up.
  set host_max-length 63

  if {![regexp -- {^(.*[^!])!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
    error "invalid nick!ident@host.domain: $nuhost"
  }

  set maskhost 1
  if {[string length $type] == "2"} {
    # Type must be 10-19.
    if {[info tclversion] < "8.1"} {
      set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
    } else {
      set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
    }
    set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

    if {![regexp -- $re_syntax $host]} {
      regsub -all -- {[0-9]} $host ? host
      set maskhost 0
    }; set type [string index $type 1]
  }

  # Previous version used regexp instead of these string matches.  String match
  # in this case is ~3 microseconds faster.
  if {[string match {[0-4]} $type]} {set nick *}
  if {[string match {[2479]} $type]} {set ident *}
  if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
  if {[string match {[3489]} $type] && $maskhost} {
    set host [lindex [split [maskhost $host] @] end]
  }

  if {[set length [string length $ident]] > ${ident_max-length}} {
    set ident *[string range $ident [expr $length-${ident_max-length}] end]
  }
  if {[set length [string length $host]] > ${host_max-length}} {
    set host *[string range $host [expr $length-${host_max-length}] end]
  }

  return $nick!$ident@$host
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:bf:replace {{args ""}} {
  mc:bf:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:bf:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:bf:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

## End of More Tools quick procs.


## SVS v3.1.1
set mc_bf(svs:client_version) "v3.1.1"
if {![info exists mc_bf(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_bf(svs:mode)]} {
  set mc_bf(svs:mode) 0
}
if {![info exists mc_bf(svs:notify)]} {
  if {![info exists owner]} {set owner ""}
  set mc_bf(svs:notify) $owner
}

bind time - "00 00 *" mc:bf:do_svs
proc mc:bf:do_svs {{args ""}} {
  global mc_bf
  mc:bf:do_svs_ $mc_bf(svs:server) $mc_bf(svs:port) $mc_bf(svs:get)
}

proc mc:bf:do_svs_ {svs_server svs_port svs_get} {
  global mc_bf tcl_platform
  if {[catch {
          socket -async $svs_server $svs_port
             } sid]} {
    putloglev d * "$mc_bf(script): SVS socket error: $sid"
    return 1
  }

  # This block of code is to get a standard User-Agent line of information, as
  # proposed in http://www.mozilla.org/build/revised-user-agent-strings.html
  foreach array_name [list platform os osVersion machine] {
    set temp($array_name) [lindex [array get tcl_platform $array_name] 1]
  }
  switch -- $temp(platform) {
    windows {
      switch -- $temp(os) {
        Windows {set temp(2) Win$temp(osVersion)}
        "Windows 95" {
          if {$temp(osVersion) < "4.10"} {
            set temp(2) Win95
          } else {
            set temp(2) Win98
          }
        }
        "Windows 98" {set temp(2) Win98}
        "Windows NT" {
          if {$temp(osVersion) >= "5.0"} {
            set temp(2) "Windows NT $temp(osVersion)"
          } else {
            set temp(2) WinNT$temp(osVersion)
          }
        }
        default {
          set temp(2) "$temp(os) $temp(osVersion)"
        }
      }
    }
    unix {
      set temp(2) "unix $temp(machine)"
    }
    macintosh {
      set temp(2) $temp(machine)
    }
    default {
      set temp(2) "$temp(os) $temp(osVersion) $temp(machine)"
    }
  }
  set temp(user_agent) "Mozilla/5.001 ($temp(platform); U; $temp(2); en) "
  append temp(user_agent) "Gecko/25250101 $mc_bf(svs:script)/"
  append temp(user_agent) "$mc_bf(svs:version) SVS_Client/"
  append temp(user_agent) "$mc_bf(svs:client_version)"
  # ^

  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:bf:svs_talk $sid timeout $svs_server $svs_port"]
  fileevent $sid readable "mc:bf:svs_talk $sid $tout"
  puts $sid "GET $svs_get?$mc_bf(svs:query) HTTP/1.0\
           \nHost: $svs_server:$svs_port\
           \nUser-Agent: $temp(user_agent)\n"
  flush $sid
}

proc mc:bf:svs_talk {sid tout {svs_server ""} {svs_port ""}} {
  global mc_bf
  set array [list svs temp $sid]
  if {$tout == "timeout"} {
    set temp(1) "$svs_server:$svs_port"
    putloglev d * \
      "$mc_bf(script): SVS Warning: Timed out connecting to $temp(1)."
    catch {unset mc_bf($array)}
    close $sid
    return 0
  }
  if {[eof $sid]} {
    catch {unset mc_bf($array)}
    close $sid
    return 1
  }
  gets $sid get
  after cancel $tout
  if {![info exist mc_bf($array)]} {
    if {$get == ""} {set mc_bf($array) 1}
    return -1
  }
  if {($get == "") || [catch {llength $get}]} {
    return -2
  }
  switch -- [lindex $get 0] {
    200 {
      set temp(host) [lindex $get 1]
      set temp(port) [lindex $get 2]
      set temp(get) [lindex $get 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * "$mc_bf(script): SVS is being redirected to $temp(cache)."
      mc:bf:do_svs_ $temp(host) $temp(port) $temp(get)
      close $sid
      return 200
    }
    003 {
      set temp(reply) [lrange $get 1 end]
      for {set number 0} {$number <= 5} {incr number} {
        set temp(reply:$number) [lindex $temp(reply) $number]
      }
      if {$temp(reply:0) != $mc_bf(svs:script)} {
        set temp(1) "wanted $mc_bf(svs:script), got $temp(reply:0)"
        putloglev d * "$mc_bf(script): SVS Error: $temp(1)"
        unset mc_bf($array)
        close $sid
        return -3
      }
      if {$mc_bf(svs:mode)} {
        set temp(svs:version) [string range $mc_bf(svs:version) 0 8]999
      } else {
        set temp(svs:version) [string range $mc_bf(svs:version) 0 11]
      }
      if {$temp(reply:1) > $temp(svs:version)} {
        set temp(note) $temp(reply:5)
        regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
        regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
        regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
        regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
        regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
        regsub -all -- %version $temp(note) $mc_bf(version) temp(note)
        foreach temp(to) [split $mc_bf(svs:notify) ",; "] {
          if {[string trim $temp(to)] == ""} {continue}
          regsub -- %nick $temp(note) $temp(to) temp(note2)
          set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
          if {[string match *$temp(note2)* $temp(lunotes)]} {
            set temp(found_note) 0
            foreach temp(unote) $temp(lunotes) {
              if {$temp(note2) == [lindex $temp(unote) 2]} {
                set temp(found_note) 1
                break
              }
            }
            if {$temp(found_note)} {continue}
          }
          set temp(error) "sending note to $temp(to) -> "
          switch -- [sendnote SVS $temp(to) $temp(note2)] {
            0 {
              if {![validuser $temp(to)]} {
                append temp(error) "invalid user"
              } else {append temp(error) "unknown error"}
              putloglev d * \
                "$mc_bf(script): SVS sendnote error: $temp(error)"
            }
            3 {
              append temp(error) "notebox too full"
              putloglev d * \
                "$mc_bf(script): SVS sendnote error: $temp(error)"
            }
          }
        }
      }
      unset mc_bf($array)
      close $sid
      return 2
    }
  }
}
## ^


putlog "$mc_bf(script) $mc_bf(version) by MC_8 loaded."

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v2.1.3 (07.06.03)
#  MC_8 - W0lF - Fixed 'integer value too large to represent'.
#                Bugzilla Bug 294 
#
# v2.1.2 (07.02.03)
#  MC_8 - W0lF - Fixed 'couldn't compile regular expression pattern: nested
#                *?+'.  Updated maskhostbytype.  v2.0 -> v2.1
#                Bugzilla Bug 293
#
# v2.1.1 (05.26.03)
#  MC_8      / - Farrago - If bantime number is too high, the ban will expire in
#  MaSsKilla               1 minute.  This is caused by the limit eggdrop puts 
#                          on the length unix time is to be.  I setup some code
#                          to detect if the bantime number will put it over
#                          eggdrop's unix time limit, and if so, auto adjust it
#                          down.
#                          Bugzilla Bug 225
#
# v2.1 (11.01.02)
#  MC_8 - - Added `key:limit` to compensate for a bug found in undernet's ircd
#           coding.  Plus, to better adjust the limit for different networks.
#  MC_8 - - Upgraded SVS Client.  v3.1 -> v3.1.1
#
# v2.0.2 (10.09.02)
#  MC_8 -         - Upgraded SVS.  v2.0 -> v3.1
#  MC_8 - Cocaine - Wasn't banning.
#  MC_8 - Alex    - Added more options on how to ban via the `bantime` variable.
#                   [bug 68]
#  MC_8 - blood_x - Fixed 'can't set "temp()": variable isn't array'.
#                   [bug 162]
#  MC_8 - Dmitry  - Fixed 'invalid command name "mc:fb:2list"', supposed to be
#                   :bf: not :fb:.  [bug 158]
#  MC_8 - Dmitry  - Fixed 'invalid command name "2list"'; Added `2list` tcl
#                   command.  none -> v1.0  [bug 157]
#  MC_8 -         - Fixed many spelling errors.
#  MC_8 -         - Reformat'd script.  The width and tabulation.
#  MC_8 -         - Moved history to bottom.
#  MC_8 -         - Upgraded Error Catching System.  v2.0 -> v3.0
#  MC_8 - blood_x - Fixed 'invalid command name "mc:bf:mc:bf:maskhostbytype"'.
#                   [bug 131]
#  MC_8 -         - Added `badargs`.  none -> v1.0
#  MC_8 -         - Added `unlist`. none -> v1.0
#  MC_8 -         - Upgraded `findnick`, change to `findnicks`.  v1.0 -> v2.0
#  MC_8 -         - Upgraded `masktype`, change to `maskhostbytype`.
#                   v1.0 -> v2.0
#  MC_8 -         - Upgraded `replace` proc, v1.1 -> v1.3
#  MC_8 - Severum - Botnet deop flood relay was doing a continuos loop.
#
# v2.0.1 (02.19.02)
#  MC_8 - - Forgot to set the SVS version correctly.  The SVS was sending notes
#           to me saying 'The version of Ban Flooders you are using is old.  The
#           current version is v2.0, and your using v2.0.'.  If you don't use
#           the SVS feature, don't worry about upgrading to v2.0.1 from v2.0.
#
# v2.0 (02.12.02)
#  MC_8 -              - Upgraded replace proc from v1.0 to v1.1.
#  MC_8 -              - Bugzilla id #38.
#  MC_8 - naba         - Fixed 'TCL error [mc:bf:flud]: invalid channel: me'.
#  MC_8 - molazem20    - Added 'mc_bf(exempt:op)' and 'mc_bf(exempt:voice)'
#                        configuration variables.
#  MC_8 - naba         - Fixed cosmetic error, was saying the ban duration in
#                        seconds rather than min's, although it was banning in
#                        mins.
#  MC_8 - naba         - Fixed cosmetic error, said 'for for' when it only needs
#                        one 'for' in the english language.
#  MC_8 - naba         - Fixed 'TCL error [mc:bf:flud]: can't use non-numeric
#                        string as operand of "!"'.
#  MC_8 - naba         - Fixed 'TCL error [mc:bf:flud]: can't read "end": no
#                        such variable'.
#  MC_8 - Ilxam Nabiev - Fixed 'TCL error [mc:bf:flud]: can't read "nmode": no
#                        such variable'.
#  MC_8 - Abraham      - Fixed 'TCL error [mc:bf:bot]: can't read "chana": no
#                        such variable'.
#  MC_8 - hyper        - Fixed 'TCL error: can't read "text": no such variable'.
#  MC_8 -              - SVS was updating of a newer version even though there
#                        wasn't... fixed.
#  MC_8 -              - Added a better error output system, for debugging
#                        purposes.
#  MC_8 -              - Fixed 'Tcl error [mc:bf:flud]: can't read "hostmask":
#                        no such variable'.
#  MC_8 -              - Added global and sticking options to ban time.
#  MC_8 -              - Added 'banmsg' setting.
#  MC_8 -              - Rewrote all settings and procs (basically the whole
#                        script).
#  MC_8 -              - Upgraded SVS v1.3 to v2.0.
#  MC_8 -              - Removed mass CTCP ignoring.  I recommend sentinel for
#                        that aspect of flood control.  Mass flooding isn't what
#                        this script is for.
#  MC_8 -              - Removed setting 'maxfluds' and 'maxfludstime', I don't
#                        see the use in them.
#
# v1.10.2 (11.02.01)
#  MC_8 - - Added a more detailed header describing this script, and also some
#           pointers on ensuring good flood protection.
#  MC_8 - - Added filtering to timer's (could cause a bug without it).
#  MC_8 - - Removed unused procs findip, lremove.
#  MC_8 - - Removed debug log coding.
#  MC_8 - - Made minor changes to the SVS client section -- to give proper error
#           if an invalid user is specified to receive a notification of a newer
#           version.
#  MC_8 - - Replaced proc mcbf:inter:findchanuser with mc:bf:findnicks.
#  MC_8 - - Rewrote the ban masking proc - much smaller, quicker and efficient.
#  MC_8 - - Added '-next' to putquick queues, making it faster to react to such
#           things as a takeover attempt (deop flood).  You must run eggdrop
#           1.5.0 to utilize the faster method, although you don't have to run
#           1.5.0 or greater if you don't want to.
#
# v1.10.1 (06.27.01)
#  Malik - - Fixed `Tcl error [mc:tw:all]: can't read "ld": no such variable`.
#  MC_8  - - Ajusted mc_bf(pub:enforce:mc) to support limit and key set's.
#  MC_8  - - The bot was removing all the modes except for the key.  Fixed.
#
# v1.10 (03.04.01)
#  MC_8  - Makik     - Was performing kicks before bans, should be the other way
#                      around.
#  Makik -           - Fixed 'Tcl error [mc:tw:all]: extra characters after
#                      close-quote'.
#  MC_8  -           - Added mc_bf(desynch) variable, I figure some people using
#                      this script REALLY don't want this feature turned on, as
#                      it was core coded to be on before.
#  MC_8  -           - Added enforce (channel lock down) for deop floods for
#                      botnet's as well.  If a bot out there is lagged, I want'
#                      him to -o+o self self, -o+b $nick $ban and lock the
#                      channel down if the bot has enough time before the lag
#                      catches up.
#  MC_8  -           - Fixed coding for deop floods, it was doing the - o+b
#                      $nick $ban correctly but it was also supposed to op self.
#                      I changed that to de synch self considering the irc
#                      server probably is going to think the bot is op'd in it's
#                      own lil lagged world.
#  MC_8  - Rami blah - If mc_bf(pub:enforce:t) was greater than 1, it still
#                      wouldn't unset mc_bf(pub:enforce:mc), rather just enforce
#                      it again.  I forgot to reverse the mode, change - to +
#                      and + to - of mc_bf(pub:enforce:mc).
#  MC_8  - Malik     - Fixed `can't unset "mc_bf(*!*@hostname)": no such element
#                      in array`.
#  MC_8  -           - Fixed an incr (increase) bug for the max floods scenario.
#  MC_8  -           - Added SVS
#  MC_8  -           - Added ability for deop floods' enforce feature to yield a
#                      timer to unset the lock-down on the channel.
#  MC_8  - Rami blah - Added ability to set a mode change upon a public flood
#                      (and a timer so it can unset it's self).
#
# v1.9.1 (08.14.00)
#  MC_8 - - Removed moretools dependency.
#  MC_8 - - eggdrop1.5.3, 1.4.4+RC1 and up changed up a lil bit of tcl, adapted.
#
# v1.9  (12-23-99)
#  MC_8 - - Fixed, on deop flood the whole script will NOT work, just error out
#           due to too many "&" signs in my IF statements.
#  MC_8 - - Fixed, was deoping damn near everyone... bot was looking to see if
#           $nick had o|o #channel witch it should be looking at $hand instead.
#  MC_8 - - Fixed, hand, no such nick error on echo'n the bitch across the
#           botnet.
#  MC_8 - - Fixed, was filling up the mode queue that was causing "OVER MAXIMUM
#           QUE!!!"
#
# v1.8  (12-20-99)
#  MC_8 - - Added mc_bf(bitch) variable set.
#  MC_8 - - Can echo and activate the mc_bf(bitch) function across the botnet
#           for extended support, snd & rcv veritable for this can be set.
#
# v1.7  (10-22-99)
#  MC_8 - - Added, If flooder is on party line, will boot (can turn it off,
#           optional).
#  MC_8 - - Fixed "mc_bf(kickbantime)" error.
#
# v1.6  (10-09-99)
#  MC_8 - - Fixed, banning <host> on me .. error no such channel me, on personal
#           floods (msg/ctcp) ... again.
#
# v1.5  (10-08-99)
#  MC_8 - - Fixed, was adding a ban even though bot wasn't op'd... I don't like
#           that.
#  MC_8 - - Fixed, banning <host> on me .. error no such channel me, on personal
#           floods (msg/ctcp).
#  MC_8 - - Added deop flood => utilize botnet for possible de sync abuse to
#           regain ops.
#  MC_8 - - Added; Search botnet for flooder also, boot if possible.
#  MC_8 - - Added ban type variable, some people like to ban in different
#           formats.
#  MC_8 - - Adjusted the way it searched other channels for the flooder, was
#           search by nick, now by (ban type).
#
# v1.4  (10-06-99)
#  MC_8 - - Fixed bots now ban on flood, even know the user isn't on the channel
#           (in between rejoin).
#
# v1.3
#  MC_8 - - Fixed a Major security risk bug, bot's deoped self on deop flood!
#
# v1.2 - v1.0
#  MC_8 - - initial release
##
