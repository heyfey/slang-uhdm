// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut(input logic [1:0] i, output logic o);
  task automatic t(input p::e_t x, output logic y);
    y = x == p::B;
  endtask
  always_comb t(p::e_t'(i), o);
endmodule
