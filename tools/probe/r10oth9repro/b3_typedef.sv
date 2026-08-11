// r10oth9 arm b3 — THE TYPEDEF CELL, which is where the last two passes both
// went wrong.
//
// § arrayVarSignedWritten8 gives the ARRAY_VAR nothing when the element type is
// a typedef NAME, because Surelog's compileVariable resolves a name to a
// typespec and never computes signedness there.  THAT IS A STATEMENT ABOUT THE
// ARRAY_VAR ONLY.  This arm asks the separate question this pass needs: what
// does golden put on the ELEMENT TYPESPEC when the element is a typedef name?
// The two carriers are NOT assumed to agree — if they disagree that is a
// REFUTATION of the natural reading of the brief and it is the point of the arm.
//
// Cells, each one line so the line number is the cell id:
//   f01/g01  `typedef byte b_t; b_t x[];`      — the plain typedef of an atom
//   f02/g02  `b_t [3:0] x[];`                  — the PACKED WRAPPER over it
//                                                (§ arrayVarSignedWritten8's
//                                                clause-(b) descent, r10oth8 F1)
//   f03/g03  a SIGNED-ENUM typedef element
//   f04/g04  `bit signed [7:0][3:0] x[];`      — the POSITIVE control: written,
//                                                signed, no typedef anywhere
//   f05/g05  a CHAINED typedef (b_t -> b2_t)
//   f06/g06  the WHOLE ARRAY through a typedef (`typedef byte barr_t[];`) —
//            clause (a)'s reason for existing
typedef byte                       b_t;
typedef b_t                        b2_t;
typedef enum bit signed [3:0] { EA, EB } se_t;
typedef byte                       barr_t[];

class fc;
  rand b_t               f01_btd[];
  rand b_t [3:0]         f02_pkbtd[];
  rand se_t              f03_setd[];
  rand bit signed [7:0][3:0] f04_written[];
  rand b2_t              f05_chain[];
  rand barr_t            f06_wholetd;
endclass

module b3_top;
  b_t                    g01_btd[];
  b_t [3:0]              g02_pkbtd[];
  se_t                   g03_setd[];
  bit signed [7:0][3:0]  g04_written[];
  b2_t                   g05_chain[];
  barr_t                 g06_wholetd;
  fc h;
  initial begin
    h = new();
    g01_btd = new[1];
    g02_pkbtd = new[1];
    g03_setd = new[1];
    g04_written = new[1];
    g05_chain = new[1];
    g06_wholetd = new[1];
  end
endmodule
