// r10v145 arm G -- ZERO-STATEMENT TF-ITEM bodies (the pristine SEGFAULT the
// implementer reports).  Every home, every declarator count.  MEASUREMENT ONLY.
package pg145v;
  function void z2145v;  int k1 = 4;  int k2 = 5;  endfunction
  function void z3145v;  int k1 = 4;  int k2 = 5; int k3 = 6;  endfunction
  function void z1145v;  int k1 = 4;  endfunction
  function void z2m145v; int k1 = 4, k2 = 5;      endfunction
  task tz2145v; input int p; int k1 = 4; int k2 = 5; endtask
  class Cz145v;
    function void mz2145v; int k1 = 4; int k2 = 5; endfunction
  endclass
endpackage

module mz145v;
  function void z2m145v;  int k1 = 4;  int k2 = 5;  endfunction
  task tz2m145v; input int p; int k1 = 4; int k2 = 5; endtask
endmodule
