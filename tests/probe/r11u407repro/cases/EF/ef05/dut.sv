// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 'h10,
    B = 'd7
  } t_e;
  function automatic logic f(t_e x);
    return (x == B) || (x != A);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
