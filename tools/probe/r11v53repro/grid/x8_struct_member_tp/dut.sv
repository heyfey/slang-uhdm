// v11u53 BREAK-8: a LOCAL TYPEDEF whose MEMBER is a type parameter.  The
// argument names the typedef (in the data-type map), so both sides should
// resolve; this is the control that the refusal is not over-broad.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  typedef struct packed { TP f; logic [2:0] g; } s_t;   // 100
  localparam int WS = $bits(s_t);
  localparam int WT = $bits(TP);          // the law's cell
  assign o = ^{WS[0], WT[0]};
endmodule
