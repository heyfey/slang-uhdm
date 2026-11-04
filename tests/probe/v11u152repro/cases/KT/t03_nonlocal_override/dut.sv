// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    parameter type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i,
    output logic     o
);
  assign o = ^rt_i;
endmodule
module top(input logic [7:0] a, output logic o);
  dut #(.rt_t(logic [7:0])) u(.rt_i(a), .o(o));
endmodule
