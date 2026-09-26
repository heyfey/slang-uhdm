// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic logic f(p::e_t x);
    return x == B;
  endfunction
endpackage
module dut(input logic [1:0] i, output logic o);
  assign o = p::f(p::e_t'(i));
endmodule
