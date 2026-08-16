set pagination off
set confirm off
break MARK
run
# Record the ARGUMENTS of the frames the backtrace names.  At function ENTRY the
# SysV ABI puts `this` in $rdi and `other` in $rsi, so these are read, not
# scraped off the stack after the fact.
set $cd_l = 0
set $cd_r = 0
set $av_l = 0
set $av_r = 0
set $ts_l = 0
set $ts_r = 0
break *UHDM::class_defn::Compare
commands
silent
set $cd_l = $rdi
set $cd_r = $rsi
continue
end
break *UHDM::array_var::Compare
commands
silent
set $av_l = $rdi
set $av_r = $rsi
continue
end
break *UHDM::array_typespec::Compare
commands
silent
set $ts_l = $rdi
set $ts_r = $rsi
continue
end
watch -l *g_watch
commands
silent
if *g_watch == g_target
  printf "\n*** FAILING STORE ***\n"
  bt 10
  call (void)SHOWL("target", (void*)g_target)
  call (void)SHOWL("cls.lhs", (void*)$cd_l)
  call (void)SHOWL("cls.rhs", (void*)$cd_r)
  call (void)SHOWL("avar.lhs", (void*)$av_l)
  call (void)SHOWL("avar.rhs", (void*)$av_r)
  call (void)SHOWL("ats.lhs", (void*)$ts_l)
  call (void)SHOWL("ats.rhs", (void*)$ts_r)
  call (void)SHOWCHAIN("AV.LHS", (void*)$av_l)
  call (void)SHOWCHAIN("AV.RHS", (void*)$av_r)
  call (void)SHOWINST("TS.LHS", (void*)$ts_l)
  call (void)SHOWINST("TS.RHS", (void*)$ts_r)
  kill
  quit
end
continue
end
continue
