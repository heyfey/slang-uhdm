module dut;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  localparam it_t I [0:1] = '{'{x: 8'd1, y: 4'd2}, '{x: 8'd3, y: 4'd4}};
  logic [11:0] z;
  initial z = I[0];
endmodule
