// ARM C — THE CORPUS TOPOLOGY.  An importing PACKAGE wildcard-imports the home
// package, so its two views each carry an IMPORT CLONE of the out-of-body
// method.  This is the arm that says whether an import clone's placeholder
// keeps the ELABORATED home package in BOTH views (the shape r10uvm183
// measured for the foreach placeholder) while the HOME package's own DEF
// listing takes its own DEF twin.
package p213c;
  class c213c #(type T213 = int);
    extern function void fc213(T213 x213);
  endclass
  function void c213c::fc213(T213 x213);
    T213 locc213;
    locc213 = x213;
  endfunction
endpackage
package q213c;
  import p213c::*;
  int q213c_v;
endpackage
module top213c;
  import p213c::*;
  import q213c::*;
  initial begin end
endmodule
