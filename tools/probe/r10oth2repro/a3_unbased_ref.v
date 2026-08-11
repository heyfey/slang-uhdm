// r10oth2 ARM A3 -- DIRECTION A, the UNMEASURED HALVES of the A1/A2 model.
//
// A1+A2 gave the model: Surelog's UHDM ExprEval bails on exactly two things,
//   (1) a SHIFT whose LEFT operand reduces to a size(-1) constant, and
//   (2) get_value/get_uvalue on a BIN constant holding X or Z digits.
// Both are properties of the REDUCED operand, not of the written syntax, so
// both must be re-measured through a PARAMETER REFERENCE (Surelog substitutes
// the referenced parameter's own elaborated constant) and through a
// CONDITIONAL (which might re-encode its selected arm and so erase size -1).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module t ();
  localparam a  = 1;
  localparam b  = 2;
  localparam z0 = '0;   // its own elab constant is BIN:0 size -1
  localparam z1 = '1;
  localparam zx = 'X;   // BIN:X size -1

  // ---- rule (1) reached through a PARAMETER REFERENCE --------------------
  localparam p1 = z0 << 1;         // left operand is a ref to an unbased param
  localparam p2 = z1 << 1;
  localparam p3 = 1 << z0;         // ref as the shift AMOUNT (must still fold)

  // ---- rule (2) reached through a PARAMETER REFERENCE --------------------
  localparam p4 = zx + 1;
  localparam p5 = z0 + 1;          // known unbased via a ref  -> must fold
  localparam p6 = (a < b) ? 1'b0 : zx;      // X ref in the UNTAKEN arm
  localparam p7 = ((a < b) ? 1'b0 : zx) + 5;  // the BlackParrotComplex shape
  localparam p8 = (a > b) ? 1'b0 : zx;      // X ref in the TAKEN arm

  // ---- does a CONDITIONAL re-encode its selected arm (erasing size -1)? --
  localparam c1 = ((a < b) ? '0 : '1) << 1;      // unbased through a ternary
  localparam c2 = ((a < b) ? 1'b0 : 1'b1) << 1;  // control: sized arms
  localparam c3 = ((a < b) ? z0 : z1) << 1;      // via refs

  // ---- a shift NESTED inside the tree, not at the root ------------------
  localparam n1 = 1 + ('0 << 2);
  localparam n2 = (a < b) ? 1'b0 : ('0 << 2);    // bailing shift, UNTAKEN arm
  localparam n3 = (a > b) ? 1'b0 : ('0 << 2);    // bailing shift, TAKEN arm

  initial $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d",
                   p1, p2, p3, p4, p5, p6, p7, p8, c1, c2, c3, n1, n2, n3);
endmodule
