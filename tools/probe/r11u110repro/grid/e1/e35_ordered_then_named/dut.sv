module child #(
    parameter type id_t = logic,
    localparam int DEPTH = (1 << $bits(id_t)),
    localparam type rt_t = id_t [DEPTH-1:0]
) (
    input  rt_t rt_i,
    input  id_t id_i,
    output logic sel_o
);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [7:0] a, input logic [7:0] b, input logic [1:0] i, output logic o, output logic p);
  child #(logic [1:0]) u (.rt_i(a), .id_i(i), .sel_o(o));
  child #(.id_t(logic [1:0])) v (.rt_i(b), .id_i(i), .sel_o(p));
endmodule
