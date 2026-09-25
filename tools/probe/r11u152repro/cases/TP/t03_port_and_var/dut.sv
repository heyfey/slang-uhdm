// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i,
    output logic     o
);
  rt_t q;
  assign q = rt_i;
  assign o = ^q;
endmodule
