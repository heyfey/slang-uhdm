// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] { A = 8'h01, B = 8'h20, C = 8'h40 } t_e;
  function automatic logic f(t_e x);
    return x inside {A, B};
  endfunction
endpackage
module top(input p::t_e i, output logic o);
  assign o = p::f(i);
endmodule
