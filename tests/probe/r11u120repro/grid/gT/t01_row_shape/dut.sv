module child #(
    parameter type id_t     = logic,
    localparam int DEPTH    = (1 << $bits(id_t)),
    localparam type rt_t    = id_t [DEPTH-1:0],
    localparam type sel_t   = logic [0:0]
) (
    input  rt_t  rt_i,
    input  id_t  id_i,
    output sel_t sel_o
);
  assign sel_o = rt_i[int'(id_i)];
endmodule
module dut (input logic [7:0] rt_i, input logic [1:0] id_i, output logic sel_o);
  child #(.id_t(logic [1:0])) u (.rt_i(rt_i), .id_i(id_i), .sel_o(sel_o));
endmodule
