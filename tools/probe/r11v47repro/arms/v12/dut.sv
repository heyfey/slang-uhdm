module dut;
  localparam int W = 8;
  localparam type a_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  localparam type b_t = a_t;
  localparam type c_t = b_t;
  localparam c_t I = '{x: 8'd1, y: 4'd2};
  logic [11:0] z;
  initial z = I;
endmodule
