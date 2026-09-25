// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i,
    output logic     o
);
  assign o = ^rt_i;
endmodule
module top(input logic [11:0] a, output logic o);
  dut #(.id_t(logic [2:0])) u(.rt_i(a), .o(o));
endmodule
