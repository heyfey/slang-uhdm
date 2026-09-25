// § streamOperandBraceSpan140
interface sif;
  logic [7:0] a;
  logic [7:0] r;
  assign r = { <<  { a } };
endinterface
module dut(input logic [7:0] x, output logic [7:0] y);
  sif s();
  assign s.a = x;
  assign y = s.r;
endmodule
