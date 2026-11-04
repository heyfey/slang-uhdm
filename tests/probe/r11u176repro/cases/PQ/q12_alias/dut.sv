// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t f_t;
endpackage
module dut(input logic [1:0] i, output logic o);
  function automatic logic f(p::f_t x);
    return x == p::B;
  endfunction
  assign o = f(p::f_t'(i));
endmodule
