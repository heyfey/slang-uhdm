// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [1:0] { A, B, C } t_e;
  function automatic t_e f(t_e x);
    return (x == A) ? B : C;
  endfunction
endpackage
module top(input p::t_e i, output p::t_e o);
  assign o = p::f(i);
endmodule
