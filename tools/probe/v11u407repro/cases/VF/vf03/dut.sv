// § pkgRetEnumOperandFold407
package p;
  typedef enum int { N = -1, Z = 0, P = 5 } t_e;
  function automatic logic f(t_e x);
    return (x == N) || (x > P);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
