module dut;
  localparam int W = 8;
  localparam type it_t = struct {
    logic [W-1:0] x;
    int           y;
  };
  localparam it_t I = '{x: 8'd1, y: 2};
  int z;
  initial z = I.y;
endmodule
