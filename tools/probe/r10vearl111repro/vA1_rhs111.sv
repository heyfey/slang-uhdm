// v111 adversarial arm A1 -- THE RHS-OBJECT AXIS.  Surelog copies the LHS
// parameter's typespec onto the substituted value ONLY when the clone has none
// of its own (`res->Typespec() == nullptr`, CompileExpression.cpp:2900/2969).
// A `localparam int` whose RHS is a SIZED literal, a typed expression or a
// system call may hand the clone a typespec of its OWN -- in which case golden
// is NOT a bare int_typespec and the law's mint is a WRONG object, not a
// missing one.  Every row here is declared `int` (or `int unsigned`), so the
// law admits all of them; only the RHS moves.
package pk1v111;
  typedef struct packed { logic [63:0] src; logic v; } h_t;
  localparam int PK = 2;
endpackage

module s1v111 (input pk1v111::h_t h_i, output logic [63:0] o);
  localparam int unsigned B1 = 2;              // unsized decimal
  localparam int unsigned B2 = 32'd2;          // SIZED 32-bit literal
  localparam int unsigned B3 = 8'd2;           // SIZED narrow literal
  localparam int unsigned B4 = 2'b10;          // SIZED binary literal
  localparam int unsigned B5 = $clog2(4);      // system function (head shape)
  localparam int unsigned B6 = 1 + 1;          // operation
  localparam int unsigned B7 = pk1v111::PK;    // package-parameter read
  localparam int unsigned B8 = 32'sd2;         // SIGNED sized literal
  localparam int unsigned B9 = 32'sh2;         // SIGNED hex sized literal
  localparam int unsigned B10 = 1;             // WIDTH-1 mint (earl55)
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[ 1: 0] = h_i.src[0 +: B1];
    assign r[ 3: 2] = h_i.src[0 +: B2];
    assign r[ 5: 4] = h_i.src[0 +: B3];
    assign r[ 7: 6] = h_i.src[0 +: B4];
    assign r[ 9: 8] = h_i.src[0 +: B5];
    assign r[11:10] = h_i.src[0 +: B6];
    assign r[13:12] = h_i.src[0 +: B7];
    assign r[15:14] = h_i.src[0 +: B8];
    assign r[17:16] = h_i.src[0 +: B9];
    assign r[19:18] = {1'b0, h_i.src[0 +: B10]};
  end
  assign o = r;
endmodule

module vA1_rhs111;
  pk1v111::h_t s;
  logic [63:0] oo;
  s1v111 u (.h_i(s), .o(oo));
endmodule
