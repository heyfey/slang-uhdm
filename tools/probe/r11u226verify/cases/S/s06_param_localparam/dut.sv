// § ndaSizeFoldReach219 § ndaAdjSizeFoldSized223 — $size of an unpacked parameter array and a localparam array with d, and of a parameter-sized variable array
module top #(parameter int N = 5)(output logic [7:0] o0, output logic [7:0] o1, output logic [7:0] o2);
  localparam int LA [3] = '{1, 2, 3};
  parameter logic [3:0] PA [2][4] = '{default: '0};
  logic [N-1:0] va [N+1];
  wire [7:0] w0 = $size(LA);
  wire [7:0] w1 = $size(PA, 2);
  wire [7:0] w2 = $size(va, 1);
  assign o0 = w0; assign o1 = w1; assign o2 = w2;
endmodule
