// § tpElemPatAtUser152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module dut import pk::*; #(
    localparam type rt_t    = s_t [3:0]
) (
    input  rt_t      rt_i,
    output logic     o
);
  assign o = ^rt_i;
endmodule
