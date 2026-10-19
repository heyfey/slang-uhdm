// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [1:0] { A, B, C } t_e;
  function automatic logic f(t_e x);
    t_e y;
    y = x;
    return (y == A) | (t_e'(2) == C);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
