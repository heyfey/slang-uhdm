// § tfFormalTdCloneFile196: a class method declared in a header whose formals use typedefs declared in dut.sv's package, and an extern method body out of class
package p;
  typedef logic [5:0] w_t;
  typedef logic [1:0] n_t;
`include "cls.svh"
  function int C::g(n_t a);
    return a;
  endfunction
endpackage
module top;
  import p::*;
endmodule
