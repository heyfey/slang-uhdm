// § ndaSizeFoldReach219 — $size of two- and three-dimensional unpacked integral arrays in net-declaration initializers
module dut (output logic [7:0] o, output logic [7:0] o2, output logic [3:0] o3);
  logic [1:0] m [2][3];
  int         t [4][2][3];
  bit         b [0:5][1:0];
  wire [7:0] w = $size(m);
  wire [7:0] w2 = $size(t);
  wire [3:0] w3 = $size(b);
  assign o = w;
  assign o2 = w2;
  assign o3 = w3;
endmodule
