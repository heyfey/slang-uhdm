// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [3:0] { A = 4'h1, B = 4'h2 } t_e;
  function automatic logic [7:0] f(t_e x);
    return {A, x};
  endfunction
endpackage
module top(input p::t_e i, output logic [7:0] o);
  assign o = p::f(i);
endmodule
