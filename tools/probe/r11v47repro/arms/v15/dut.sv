package pk;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
endpackage
module dut;
  import pk::*;
  localparam pk::it_t I = '{x: 8'd1, y: 4'd2};
  logic [11:0] z;
  initial z = I;
endmodule
