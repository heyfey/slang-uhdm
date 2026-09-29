// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the last dimension of a one-unpacked one-packed operand, and a 3-D mixed operand read at each dimension
module dut (output logic [7:0] o1, o2, o3, o4);
  logic [3:0] m [5];
  logic [2:0][1:0] m3 [4];
  wire [7:0] w1 = $size(m, 2);
  assign o1 = w1;
  wire [7:0] w2 = $size(m3, 1);
  assign o2 = w2;
  wire [7:0] w3 = $size(m3, 2);
  assign o3 = w3;
  wire [7:0] w4 = $size(m3, 3);
  assign o4 = w4;
endmodule
