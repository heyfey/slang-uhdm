// § caStructSetterCastMemberWidthNoFold301
module dut (output logic [7:0] b_o);
  typedef struct packed { int unsigned W; } w_t;
  localparam w_t L = '{W: 32'd8};
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: L.W'(1), y: L.W'(2)};
  assign b_o = I.y;
endmodule
