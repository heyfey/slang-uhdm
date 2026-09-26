// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut import p::*; (input logic [1:0] i, output logic o, q);
  function automatic logic f(p::e_t x);
    return x == B;
  endfunction
  function automatic logic g(e_t x);
    return x == C;
  endfunction
  assign o = f(e_t'(i));
  assign q = g(e_t'(i));
endmodule
