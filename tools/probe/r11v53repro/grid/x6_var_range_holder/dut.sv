// v11u53 BREAK-6: the holder is a module-body VARIABLE's PACKED RANGE, which
// reaches the emitter through TypeEmit.cpp's srlgBitsFoldArg call site rather
// than ParamEmit's.  (The PORT-range and NET-range holders are
// weaklyReferenced-only and unjudged; a body variable is in the listing.)
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = pk::req_t
) (
    input  logic clk_i,
    output logic o
);
  logic [$bits(TP)-1:0]        r;        // TYPE PARAMETER in a var range
  logic [$bits(pk::req_t)-1:0] s;        // CONTROL
  always_ff @(posedge clk_i) r <= {r[0], r[$bits(TP)-1:1]};
  assign s = r;
  assign o = ^{r, s};
endmodule
