// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    localparam type rt_t    = id_t [3:0]
) (
    input  logic [7:0] a,
    output logic     o
);
  rt_t q;
  assign q = a;
  assign o = ^q;
endmodule
