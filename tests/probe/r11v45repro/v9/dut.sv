// v9 — a named STRUCT typedef as the chain source, plus a chained param used
// as a port type in a GENERATE block.
typedef struct packed { logic [7:0] a; logic b; } s_t;
module dut #(
    parameter type a_t = s_t,
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  genvar g;
  generate for (g = 0; g < 2; g++) begin : gb
    b_t w;
    assign w = i;
  end endgenerate
  assign o = ^i;
endmodule
