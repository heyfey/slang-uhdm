module dut;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  typedef it_t alias_t;
  localparam alias_t J = '{x: 8'd1, y: 4'd2};
  localparam it_t    I = '{x: 8'd3, y: 4'd4};
  logic [11:0] z;
  initial z = J ^ I;
endmodule
