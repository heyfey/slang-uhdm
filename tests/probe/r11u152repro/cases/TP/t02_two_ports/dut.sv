// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i,
    input  rt_t      rt2_i,
    output logic     o
);
  assign o = ^{rt_i, rt2_i};
endmodule
