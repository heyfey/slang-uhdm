// § ndaSizeQueryFold216 — $size of a ranged parameter and of a logic variable in net initializers
module dut (output logic [7:0] o, output logic [7:0] o2);
  parameter [9:4] a = 3;
  logic [0:2] v;
  wire [7:0] w = $size(a);
  wire [7:0] x = $size(v);
  assign o = w;
  assign o2 = x;
endmodule
