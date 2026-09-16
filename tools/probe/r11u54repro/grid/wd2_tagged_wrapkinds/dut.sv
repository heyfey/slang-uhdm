// r11u54 arm — LAW D, THE CUT THE BRIEF DID NOT MAKE.  vd1/wd1 measure the
// FLAT (expandPatternAssignment) form, where golden re-stamps every element to
// the member width.  This arm holds the TAGGED tree alive — a SYMBOLIC member
// dimension keeps Surelog from typing the pattern op, so its flatten never runs
// — and varies only the element's WRAPPER KIND, so that "which elements get the
// member width when the tagged tree SURVIVES" is the only free variable.
package pk;
  parameter int unsigned NR = 2;
  typedef struct packed {
    int unsigned         A;   // bare literal 64        (64 -> member 32?)
    int unsigned         B;   // unsigned'(64)
    int unsigned         C;   // $unsigned(64)
    logic [7:0]          D;   // 32'(5), a SIZE CAST
    int unsigned         E;   // NR + 1, an OPERATION
    logic [NR-1:0][63:0] L;   // SYMBOLIC dim: this is what keeps the tags
  } u_t;
  localparam u_t BASE = '{ A: 64,
                           B: unsigned'(64),
                           C: $unsigned(64),
                           D: 32'(5),
                           E: NR + 1,
                           L: 128'({64'b0, 64'b0}) };
endpackage
module dut #(parameter pk::u_t P = pk::BASE) (output logic [31:0] o);
  assign o = P.A;
endmodule
