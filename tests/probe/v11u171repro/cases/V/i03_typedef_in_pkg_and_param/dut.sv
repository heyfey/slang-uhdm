// § boundLitWrittenDigits172
package p;
  typedef logic [015:00] w_t;
  parameter logic [03:0] P = 4'h3;
endpackage
module dut(input p::w_t a, output logic [15:0] y);
  assign y = a + p::P;
endmodule
