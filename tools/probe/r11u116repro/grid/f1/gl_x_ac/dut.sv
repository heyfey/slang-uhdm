module dut ();
  logic [31:0] a [2];
  logic o1 [2];
  logic [31:0] o2 [2];
  logic o3 [2];
  logic o4 [2];
  logic [31:0] o5 [2];
  logic [31:0] o6 [2];
  logic [31:0] o7 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    localparam int unsigned M = 'hFFF;
    always_comb begin
      o1[c] = (a[c] & ~M) == 32'd0;
      o2[c] = M;
      o3[c] = a[c][M % 32];
      o4[c] = a[c] == M;
      o5[c] = a[c] + M;
      o6[c] = a[c][M-4064:M-4065];
      o7[c][M % 32] = a[c][0];
    end
  end
endmodule
