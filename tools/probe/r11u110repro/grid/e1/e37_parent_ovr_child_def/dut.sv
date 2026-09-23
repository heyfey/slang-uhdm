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
module mid #(parameter type id_t = logic) (input logic [7:0] a, input logic [1:0] i, output logic o);
  child u (.rt_i(a), .id_i(i[0]), .sel_o(o));
endmodule
module dut(input logic [7:0] a, input logic [1:0] i, output logic o);
  mid #(.id_t(logic [1:0])) m (.a(a), .i(i), .o(o));
endmodule
