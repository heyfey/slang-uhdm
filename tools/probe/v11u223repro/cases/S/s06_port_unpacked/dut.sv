// § ndaAdjSizeFoldSized223
module dut (input logic [3:0] ip [2], input bit [3:0][1:0] pp, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(ip);
  wire [2:0] w2 = $size(pp);
  assign o1 = w1; assign o2 = w2;
endmodule
