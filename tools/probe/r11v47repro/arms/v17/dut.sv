package pk;
  typedef struct packed { logic [7:0] x; logic [3:0] y; } named_t;
  localparam type it_t = named_t;
  localparam it_t I = '{x: 8'd1, y: 4'd2};
endpackage
module dut;
  logic [11:0] z;
  initial z = pk::I;
endmodule
