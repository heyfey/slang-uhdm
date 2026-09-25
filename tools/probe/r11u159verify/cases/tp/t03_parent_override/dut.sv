// § tpElemPatAtUser152
module dut #(
    parameter type id_t = logic [1:0],
    localparam type rt_t = id_t [3:0]
) (
    output rt_t rt_o
);
  assign rt_o = '1;
endmodule
module top(output logic [11:0] o);
  dut #(.id_t(logic [2:0])) u(.rt_o(o));
endmodule
