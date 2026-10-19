// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [1:0] { A, B, C } t_e;
  function automatic logic g(t_e x); return x[0]; endfunction
  function automatic logic f(t_e x);
    return g(A) ^ (x == B);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
