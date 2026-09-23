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
module mid2 #(parameter type id_t = logic) (input logic [63:0] a, input logic [3:0] i, output logic o);
  child u (.rt_i(a), .id_i(i), .sel_o(o));
endmodule
module mid1 (input logic [63:0] a, input logic [3:0] i, output logic o);
  mid2 #(.id_t(logic [2:0])) n (.a(a), .i(i), .o(o));
endmodule
module dut(input logic [63:0] a, input logic [3:0] i, output logic o);
  mid1 m (.a(a), .i(i), .o(o));
endmodule
