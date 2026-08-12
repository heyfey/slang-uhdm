// r10earl29 VERIFIER arm v1 — the SCOPED-NAME axis the shipped grid never built.
// `idxDecompile`'s NamedValue case emits `sym.name`, which DROPS any package or
// class qualifier the source wrote.  Base renders the raw text `pkv::SP`, so this
// is a cell where the patch CHANGES the string; if golden keeps the qualifier the
// change is an OVER-FIRE, and campaign memory has a whole dead-end note about
// `pkg::pkg::` naming being context-dependent.
package pkv;
  parameter logic [1:0] SP = 2'd1;
  typedef enum logic [1:0] {SE0, SE1, SE2} se_t;
endpackage
module v1_scope (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, pkv::SP}];       // SCOPED pkg parameter
    o2 = q.autoexecprogbuf[{1'b1, pkv::SE1}];      // SCOPED pkg enum literal
    o3 = q.autoexecprogbuf[{1'b1, k[0], pkv::SP}]; // scoped, THIRD position
    o4 = q.autoexecprogbuf[{pkv::SE1, k[0]}];      // scoped enum, FIRST position
  end
endmodule
module v1_scope_imp (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2
);
  import pkv::*;
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, SE1}];  // WILDCARD-IMPORTED pkg enum literal
    o2 = q.autoexecprogbuf[{k[0], SE1}];  // ditto, first position
  end
endmodule
