// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [69:0] { A = 70'h1, B = 70'h3F_0000_0000_0000_0000 } t_e;
  function automatic logic f(t_e x);
    return (x == A) || (x == B);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  import p::*;
  assign o = f(i);
endmodule
