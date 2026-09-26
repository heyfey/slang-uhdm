// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut(input logic [1:0] i, output logic o, q);
  function automatic logic f(p::e_t x);
    return x == p::B;
  endfunction
  function automatic logic g(logic y,
                             p::e_t x);
    return x == p::C;
  endfunction
  assign o = f(p::e_t'(i));
  assign q = g(1'b0, p::e_t'(i));
endmodule
