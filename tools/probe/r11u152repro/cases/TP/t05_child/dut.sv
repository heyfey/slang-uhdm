// § tpElemPatAtUser152
module child #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i,
    output logic     o
);
  assign o = ^rt_i;
endmodule
module dut(input logic [7:0] a, output logic o);
  child u(.rt_i(a), .o(o));
endmodule
