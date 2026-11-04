// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [1:0] {
    A,
    B
  } t_e;
  function automatic logic f(t_e x);
    return (x != A);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
