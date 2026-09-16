// r11u53 ROAD A — the $bits of a type parameter is NOT the whole Rhs.
//
// The two landed-law witnesses in the blast radius (`type_param_packed_dim`,
// `type_param_override_elem_sel`) both write `(1 << $bits(<type parameter>))`,
// so the fold decision is asked of a NODE INSIDE a surviving expression, not
// of the parameter's whole initializer.  The producer's gate is per-`$bits`
// (`CompileHelper::compileBits`, Surelog CompileExpression.cpp:4686) and knows
// nothing about the holder, so the prediction is: the call survives and the
// operation around it cannot reduce either.  This arm is what makes that
// prediction falsifiable before the corpus rows are read.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = logic [1:0],
    parameter type TQ = pk::req_t
) (
    output logic o
);
  localparam int S1 = (1 << $bits(TP));      // shift over a kept call
  localparam int S2 = $bits(TP) + 1;         // add  over a kept call
  localparam int S3 = (1 << $bits(pk::req_t)); // CONTROL: foldable argument
  localparam int S4 = $bits(TQ);             // the whole-Rhs cell, for contrast
  assign o = ^{S1[0], S2[0], S3[0], S4[0]};
endmodule
