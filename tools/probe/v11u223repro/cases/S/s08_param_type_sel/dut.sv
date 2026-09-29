// § ndaAdjSizeFoldSized223
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  parameter logic [3:0] P [3] = '{4'd1, 4'd2, 4'd3};
  bit [3:0][1:0] bp;
  e_t ea [5];
  wire [7:0] w1 = $size(P);
  wire [7:0] w2 = $size(e_t);
  wire [2:0] w3 = $size(bp[1]);
  wire [2:0] w4 = $size(ea[2]);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4;
endmodule
