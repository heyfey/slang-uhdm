// § sizeBitNetIsVar228 — the two-argument form on an ANSI bit port, dimension 1 and 2, and a 1-D bit port asked for dimension 1
module dut (input bit [3:0][1:0] pp, input bit [5:0] p1, output logic [7:0] o1, o2, o3);
  wire [7:0] w1 = $size(pp, 1);
  wire [7:0] w2 = $size(pp, 2);
  wire [7:0] w3 = $size(p1, 1);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
