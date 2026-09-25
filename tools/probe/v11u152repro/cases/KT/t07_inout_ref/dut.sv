// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  rt_t      rt_i [2],
    output logic     o
);
  assign o = ^rt_i[0];
endmodule
