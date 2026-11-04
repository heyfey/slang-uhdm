// § pkgRetEnumOperandFold407
package q;
  typedef enum logic [7:0] { A = 'h01, B = 'h20 } t_e;
endpackage
package p;
  import q::*;
  function automatic logic f(t_e x);
    return (x != A) && (x != B);
  endfunction
endpackage
module top(input q::t_e i, output logic o);
  assign o = p::f(i);
endmodule
