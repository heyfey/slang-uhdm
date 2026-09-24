module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input  logic [7:0] a_i,
    output rt_t r_o
);
  assign r_o = a_i;
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.a_i(a), .r_o(o));
endmodule
