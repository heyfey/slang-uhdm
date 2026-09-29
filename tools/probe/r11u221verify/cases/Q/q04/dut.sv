// § ndaSizeQueryFold216 — $size of multi-dimensional unpacked arrays (confirm pass 216 f14: golden folds, the law declines), $size with a dimension argument
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  logic [1:0] m [2][3];
  logic       n [4][5];
  logic [3:0] k [0:6];
  wire [7:0] w1 = $size(m);
  wire [7:0] w2 = $size(n);
  wire [7:0] w3 = $size(m, 2);
  wire [7:0] w4 = $size(k);
  assign o1 = w1;
  assign o2 = w2;
  assign o3 = w3;
  assign o4 = w4;
endmodule
