// § ndaAdjSizeFoldSized223 — generic-handler $size values folded into a 1-bit net (masked to 0), an ascending [0:9] net and a 40-bit signed net, beside an interface net
interface bus_i;
  int ia [3];
  wire [4:0] iw = $size(ia, 2);
endinterface
module top(output logic o1, output logic [0:9] o2, output logic signed [39:0] o3);
  bit [5:0][1:0] bp;
  bus_i u_b();
  wire w1 = $size(bp);
  wire [0:9] w2 = $size(bp, 2);
  wire signed [39:0] w3 = $size(bp);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
