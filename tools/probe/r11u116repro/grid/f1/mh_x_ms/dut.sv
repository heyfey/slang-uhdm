module dut #(parameter int unsigned M = 'hFFF) ();
  logic [31:0] a [2];
  logic o1 [2];
  logic [31:0] o2 [2];
  logic o3 [2];
  logic o4 [2];
  logic [31:0] o5 [2];
  logic [31:0] o6 [2];
  logic [31:0] o7 [2];
  localparam int c = 0;
  assign o1[c] = (a[c] & ~M) == 32'd0;
  assign o2[c] = M;
  assign o3[c] = a[c][M % 32];
  assign o4[c] = a[c] == M;
  assign o5[c] = a[c] + M;
  assign o6[c] = a[c][M-4064:M-4065];
  assign o7[c][M % 32] = a[c][0];
endmodule
