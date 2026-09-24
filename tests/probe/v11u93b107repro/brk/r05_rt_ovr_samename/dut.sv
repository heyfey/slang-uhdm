module child #(
    parameter type id_t     = logic,
    parameter int DEPTH     = (1 << $bits(id_t)),
    parameter type rt_t     = id_t [DEPTH-1:0]
) (input rt_t rt_i, input id_t id_i, output logic sel_o);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [5:0] rt_i, input logic [2:0] id_i, output logic [1:0] sel_o);
  typedef logic [2:0] id_t;
  child #(.id_t(logic [1:0])) u0(.rt_i(rt_i[3:0]), .id_i(id_i[1:0]), .sel_o(sel_o[0]));
  child #(.rt_t(id_t [1:0])) u1(.rt_i(rt_i), .id_i(id_i[0]), .sel_o(sel_o[1]));
endmodule
