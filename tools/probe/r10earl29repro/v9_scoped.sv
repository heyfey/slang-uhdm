// r10earl29 VERIFIER arm v9 — the SCOPED package parameter with NO wildcard
// import ANYWHERE in the design.  v1_scope could not decide this cell: its second
// module imports `pkv::*`, and `importedParamDefTs` is keyed on the PARAMETER
// SYMBOL for the whole design, so the abstention fired for the scoped use as a
// side effect of the other module's import.  This arm removes that side effect.
package pkw;
  parameter logic [1:0] WP = 2'd1;
  typedef enum logic [1:0] {WE0, WE1, WE2} we_t;
endpackage
module v9_scoped (
    output logic o1,
    output logic o2
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t q;
  logic [3:0] k;
  always_comb begin
    o1 = q.autoexecprogbuf[{1'b1, pkw::WP, k[0]}];  // SCOPED pkg parameter, no import
    o2 = q.autoexecprogbuf[{1'b1, pkw::WE1, k[0]}]; // SCOPED pkg enum literal
  end
endmodule
