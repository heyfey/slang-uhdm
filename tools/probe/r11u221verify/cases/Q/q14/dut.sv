// § ndaSizeQueryFold216 — $size of a descending and an ascending vector onto nets of different widths, a signed and an explicit-logic net
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  logic [0:9] v;
  logic [15:0] u;
  wire logic [2:0] w1 = $size(v);
  wire signed [5:0] w2 = $size(u);
  wire [7:0] w3 = $size(v) ;
  assign o1 = w1;
  assign o2 = w2;
  assign o3 = w3;
endmodule
