// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] { A = 'h01, B = 'h20 } t_e;
  function automatic logic f(t_e x);
    return !(x == A) && -B;
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
