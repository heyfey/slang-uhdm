// r10uvm86 arm a4 — the SCOPE ladder: which COMPILE reaches Reduce::Yes.
// Package (CompilePackage Reduce::Yes / Reduce::No pair) vs module
// (CompileModule, Reduce::No) vs $unit (CompileFileContent, Reduce::No),
// plus the WILDCARD-IMPORT clone views.
package p4a;
  class c4a;
    int g;
    extern function int oob_ret();
    extern task oob_task();
    function int inb_ret(); return -1; endfunction
  endclass
  function int c4a::oob_ret(); return -1; endfunction
  task c4a::oob_task(); g = -1; endtask
  function int p4a_own(); return -1; endfunction
endpackage
package p4b;
  import p4a::*;
  function int p4b_own(); return -1; endfunction
endpackage
module m4;
  import p4a::*;
  class c4m;
    int g;
    extern function int mod_oob();
    function int mod_inb(); return -1; endfunction
  endclass
  function int c4m::mod_oob(); return -1; endfunction
  function int m4_own(); return -1; endfunction
  int r;
  initial r = p4a_own();
endmodule
function int unit_own(); return -1; endfunction
