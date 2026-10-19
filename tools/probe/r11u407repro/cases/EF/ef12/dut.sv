// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 8'h00,
    B = 8'h20
  } t_e;
endpackage
package q;
  import p::*;
  function automatic logic f(t_e x);
    return (x != A);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = q::f(i);
endmodule
