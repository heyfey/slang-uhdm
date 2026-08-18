// r10buvm17 arm a2 — THE HOME GUARD.  The same foreach body compiled in every
// home a design can offer, with a TOP MODULE present so Surelog elaborates the
// design: a module function, a module task, a module `initial`, an out-of-body
// method of a class declared INSIDE a module, a `$unit` function, a program, an
// interface, and (for contrast) the package shapes arm a1 measures alone.
//
// MEASUREMENT ONLY.  Nothing here is an acceptance judge.
function automatic void unitfn17(ref byte ub17[]);
  int a17 = 0;
  foreach (ub17[i]) a17 = a17 + i;
endfunction

package hp17;
  class HC17;
    extern function void hoob17(ref byte hb17[]);
  endclass
  function void HC17::hoob17(ref byte hb17[]);
    int a17 = 0;
    foreach (hb17[i]) a17 = a17 + i;
  endfunction
  function automatic void hfree17(ref string hs17[]);
    int a17 = 0;
    foreach (hs17[i]) a17 = a17 + i;
  endfunction
endpackage

interface if17;
  function automatic void iffn17(ref byte ib17[]);
    int a17 = 0;
    foreach (ib17[i]) a17 = a17 + i;
  endfunction
endinterface

program prog17;
  function automatic void pgfn17(ref byte pb17[]);
    int a17 = 0;
    foreach (pb17[i]) a17 = a17 + i;
  endfunction
endprogram

module top17;
  import hp17::*;

  byte marr17[];
  string msarr17[];

  class MC17;
    extern function void moob17(ref byte mb17[]);
  endclass
  function void MC17::moob17(ref byte mb17[]);
    int a17 = 0;
    foreach (mb17[i]) a17 = a17 + i;
  endfunction

  function automatic void mfn17(ref byte fb17[]);
    int a17 = 0;
    foreach (fb17[i]) a17 = a17 + i;
  endfunction

  task automatic mtask17(ref string ts17[]);
    int a17 = 0;
    foreach (ts17[i]) a17 = a17 + i;
  endtask

  initial begin
    int a17 = 0;
    foreach (marr17[i]) a17 = a17 + i;
    foreach (msarr17[j]) a17 = a17 + j;
  end
endmodule
