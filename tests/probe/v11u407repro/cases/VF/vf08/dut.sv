// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [3:0] { A = 4'b10x0, B = 4'b0001 } t_e;
  function automatic logic f(t_e x);
    return x === A;
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
