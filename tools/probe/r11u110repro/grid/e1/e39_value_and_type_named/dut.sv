module child #(
    parameter int W = 1,
    parameter type id_t = logic,
    localparam type rt_t = id_t [W-1:0]
) (input rt_t rt_i, output logic sel_o);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [7:0] a, output logic o);
  child #(.W(4), .id_t(logic [1:0])) u (.rt_i(a), .sel_o(o));
endmodule
