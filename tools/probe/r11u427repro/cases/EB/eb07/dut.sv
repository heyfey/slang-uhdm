// § elabBasedLitLowerBase427
interface ifc #(parameter B = 4'B10x1, parameter H = 'HF0)(input logic clk);
  logic [7:0] v;
endinterface
module top(input logic clk, output logic [7:0] o);
  ifc i1(clk);
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam X = 4'B1x0x;
  end
  assign o = i1.v;
endmodule
