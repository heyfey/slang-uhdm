// § tpRebindIdOrder259 (three definitions rebound, instantiated in the reverse of their declaration order)
module ca #(
    parameter type id_t     = logic,
    localparam int DEPTH    = (1 << $bits(id_t)),
    localparam type rt_t    = id_t [DEPTH-1:0]
) (input rt_t rt_i, input id_t id_i, output logic sel_o);
  assign sel_o = ^rt_i[int'(id_i)];
endmodule
module cb #(
    parameter type id_t     = logic,
    localparam int DEPTH    = (1 << $bits(id_t)),
    localparam type rt_t    = id_t [DEPTH-1:0]
) (input rt_t rt_i, input id_t id_i, output logic sel_o);
  assign sel_o = ^rt_i[int'(id_i)];
endmodule
module cc #(
    parameter type id_t     = logic,
    localparam int DEPTH    = (1 << $bits(id_t)),
    localparam type rt_t    = id_t [DEPTH-1:0]
) (input rt_t rt_i, input id_t id_i, output logic sel_o);
  assign sel_o = ^rt_i[int'(id_i)];
endmodule
module dut(input logic [15:0] rt_i, input logic [2:0] id_i, output logic [2:0] sel_o);
  cc #(.id_t(logic [1:0])) u2(.rt_i(rt_i[3:0]), .id_i(id_i[1:0]), .sel_o(sel_o[2]));
  cb #(.id_t(logic [1:0])) u1(.rt_i(rt_i[7:4]), .id_i(id_i[1:0]), .sel_o(sel_o[1]));
  ca #(.id_t(logic [2:0])) u0(.rt_i(rt_i[15:8]), .id_i(id_i), .sel_o(sel_o[0]));
endmodule
