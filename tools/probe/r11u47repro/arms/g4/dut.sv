module dut #(parameter int W = 8) (input logic a_i, output logic [W-1:0] b_o);
  typedef struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  } named_t;
  localparam type it_t = named_t;
  localparam it_t I = '{x: W'(1), y: W'(2)};
  assign b_o = a_i ? I.x : I.y;
endmodule
