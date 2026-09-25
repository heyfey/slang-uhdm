// § tpElemPatAtUser152
package pk;
  typedef logic [1:0] id_t;
endpackage
module dut #(
    parameter type e_t = pk::id_t,
    localparam type rt_t = e_t [3:0]
) (
    input  rt_t rt_i,
    output logic o
);
  assign o = ^rt_i;
endmodule
