// § foldedBoundTsRefUnstored144
module dut(a, y);
  parameter int P = 4;
  input logic [P-1:0] a;
  output logic [P-1:0] y;
  assign y = a;
endmodule
