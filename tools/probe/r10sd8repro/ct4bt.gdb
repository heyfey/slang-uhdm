set pagination off
set confirm off
break MARK
run
watch -l *g_watch
commands
silent
if *g_watch == g_target
  printf "\n*** FAILING STORE — naming every register that is a live UHDM object ***\n"
  bt 8
  printf "-- ORACLE SELFTEST (must name the target) --\n"
  call (void)SHOW1((void*)g_target)
  printf "-- rdi --\n"
  call (void)SHOW1((void*)$rdi)
  printf "-- rsi --\n"
  call (void)SHOW1((void*)$rsi)
  printf "-- rdx --\n"
  call (void)SHOW1((void*)$rdx)
  printf "-- rbx --\n"
  call (void)SHOW1((void*)$rbx)
  printf "-- rbp --\n"
  call (void)SHOW1((void*)$rbp)
  printf "-- r12 --\n"
  call (void)SHOW1((void*)$r12)
  printf "-- r13 --\n"
  call (void)SHOW1((void*)$r13)
  printf "-- r14 --\n"
  call (void)SHOW1((void*)$r14)
  printf "-- r15 --\n"
  call (void)SHOW1((void*)$r15)
  printf "-- rax --\n"
  call (void)SHOW1((void*)$rax)
  printf "-- rcx --\n"
  call (void)SHOW1((void*)$rcx)
  printf "-- stack words --\n"
  set $i = 0
  while $i < 4096
    call (void)SHOW1(*(void**)($sp + $i*8))
    set $i = $i + 1
  end
  kill
  quit
end
continue
end
continue
