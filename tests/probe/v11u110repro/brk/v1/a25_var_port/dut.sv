module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input var rt_t rt_i,
    output rt_t rt_o
);
  assign rt_o = rt_i;
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.rt_i(a), .rt_o(o));
endmodule
