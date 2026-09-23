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
typedef enum logic [1:0] {A, B, C, D} e_t;
module dut(input logic [7:0] a, input logic [1:0] i, output logic o);
  child #(.id_t(e_t)) u (.rt_i(a), .id_i(e_t'(i)), .sel_o(o));
endmodule
