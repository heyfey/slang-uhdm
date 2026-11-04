// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 8'h00,
    B = 8'h20
  } t_e;
  function automatic t_e f(logic s);
    if (s) return A;
    return B;
  endfunction
endpackage
module top(input logic i, output p::t_e o);
  assign o = p::f(i);
endmodule
