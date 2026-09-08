// ARM G — the PACKAGE FREE SUBROUTINE control.  A package function's own body
// local already takes `pkgScopeInst`, which r10uvm183 recorded as
// view-correct.  This arm re-measures that claim in the same run as the law,
// so a regression there cannot hide behind it.
package p213g;
  typedef struct packed { bit [3:0] a213; } s213_t;
  function automatic void fg213(s213_t x213);
    s213_t locg213;
    locg213 = x213;
  endfunction
  class c213g;
    extern function void gg213();
  endclass
  function void c213g::gg213();
    s213_t locgg213;
    locgg213.a213 = 4'h1;
  endfunction
endpackage
module top213g;
  initial begin end
endmodule
