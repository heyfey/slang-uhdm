// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut import p::*; (input logic [1:0] i, output logic o);
  function automatic logic f(input e_t x);
    return x == B;
  endfunction
  assign o = f(e_t'(i));
endmodule
