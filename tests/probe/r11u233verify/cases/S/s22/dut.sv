// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a two-dimensional unpacked string array and a byte array
module dut (output logic [7:0] o1, o2, o3, o4);
  string st [2][3];
  byte by [4];
  wire [7:0] w1 = $size(st);
  assign o1 = w1;
  wire [7:0] w2 = $size(st, 2);
  assign o2 = w2;
  wire [7:0] w3 = $size(by);
  assign o3 = w3;
  wire [7:0] w4 = $size(by, 2);
  assign o4 = w4;
endmodule
