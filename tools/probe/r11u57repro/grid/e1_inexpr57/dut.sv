// r11u57 ROAD A, THE ELABORATED HALF — the `$bits` of a type parameter is
// BURIED INSIDE a surviving operation.
//
// r11u53 (`§ bitsTypeParamArgNeverFolds53`) landed the refusal for the
// DEFINITION view and, in the ELABORATED view, for a WHOLE-Rhs `$bits`.  Its
// R2/R1 residue is this arm: a `$bits(<type parameter>)` that is one OPERAND
// of an operation golden keeps in BOTH views.  The producer's gate is
// per-`$bits` (`CompileHelper::compileBits`, Surelog CompileExpression.cpp:
// 4686, self-upgrading at :4750-4756 per EXPRESSION), so the prediction is
// that every one of these cells keeps the call in both listings.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = logic [1:0],
    parameter type TQ = pk::req_t,
    parameter int  WID = 5
) (
    output logic o
);
  localparam int S1 = (1 << $bits(TP));        // shift over a kept call
  localparam int S2 = $bits(TP) + 1;           // add over a kept call
  localparam int S3 = $bits(TP) * 2 - 3;       // nested arithmetic
  localparam logic [7:0] S4 = {$bits(TP){1'b1}}; // REPLICATION count
  localparam int S5 = (1 << $bits(pk::req_t)); // CONTROL: foldable argument
  localparam int S6 = $bits(TQ);               // whole-Rhs (the LANDED cell)
  localparam int S7 = $bits(TP) + $bits(TQ);   // TWO kept calls in one op
  localparam int S8 = WID + $bits(TP);         // composition with a sibling
  assign o = ^{S1[0], S2[0], S3[0], S4[0], S5[0], S6[0], S7[0], S8[0]};
endmodule
