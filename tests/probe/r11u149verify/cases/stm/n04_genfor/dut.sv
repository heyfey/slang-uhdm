// § streamOperandBraceSpan140
module dut(input logic [15:0] x, output logic [15:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i*8 +: 8] = { >>	{ x[i*8 +: 4], x[i*8+4 +: 4] } };
  end
endmodule
