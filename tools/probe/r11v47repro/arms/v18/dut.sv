module dut;
  localparam int W = 4;
  localparam type it_t = struct packed {
    struct packed { logic [W-1:0] lo; logic [W-1:0] hi; } inner;
    logic [3:0] y;
  };
  localparam it_t I = '{inner: '{lo: 4'd1, hi: 4'd2}, y: 4'd3};
  logic [11:0] z;
  initial z = I;
endmodule
