interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_w1 #(parameter int R = 4)(input logic clk);
  logic          v_logic [R];
  wire           n_wire  [R];
  bit  [7:0]     v_bit   [R];
  int            v_int   [R];
  logic [R-1:0]  v_packed;
  typedef logic [R-1:0] td_t;
  td_t           v_td;
  localparam int LP [R] = '{default:0};
  logic          v_2d [R][R];
  struct packed { logic [R-1:0] f; } v_st;
endmodule
module top;
  logic clk;
  leaf_w1 #(.R(6)) u (clk);
endmodule
