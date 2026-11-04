// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 'b000_00000,
    B = 'b001_00000
  } t_e;
  function automatic logic f(t_e x);
    return (x != A);
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
