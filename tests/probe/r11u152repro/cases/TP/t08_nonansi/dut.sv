// § tpElemPatAtUser152
module dut #(
    parameter type id_t     = logic [1:0],
    parameter type rt_t    = id_t [3:0]
) (rt_i, o);
  input  rt_t      rt_i;
  output logic     o;
  assign o = ^rt_i;
endmodule
