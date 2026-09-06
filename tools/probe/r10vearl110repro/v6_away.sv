// r10vearl110 arm v6 -- THE AWAY CONSTRUCTION.
//
// v5 cell e1 measured that golden does NOT fold a localparam DECLARED INSIDE
// the generate block: golden renders `chan[z].fld[0+:9 - INNER]` -- MA (module
// scope) folds, INNER (gen-block scope) stays SPELLED.  The patch folds BOTH.
//
// On its own that is only a MOVEDWRONG, because the pristine binary printed the
// raw source text `MA-INNER` and was wrong too.  But the pristine binary prints
// the RAW SOURCE TEXT.  So if the source ALREADY WRITES the other leaf as a
// literal, with prettyPrint's exact spacing, then
//     pristine == golden  (raw text `8 - INNER` is what golden renders)
//     patched  != golden  (it folds INNER to 4 -> `8 - 4`)
// which is an AWAY on legal, ordinary SV.  Cells w1..w4 are that construction.
// w5..w8 are the controls that must NOT move.
package pv6;
  typedef struct packed { logic [31:0] fld; } c_t;
endpackage

module v6_away #(parameter int unsigned NCH = 2) (
  input  pv6::c_t chan [NCH],
  output logic [31:0] oz
);
  localparam int unsigned MOD = 9;      // module scope -- golden FOLDS this
  logic [31:0] w1,w2,w3,w4,w5,w6,w7,w8;

  for (genvar z = 0; z < NCH; z++) begin : blk_w
    localparam int unsigned INNER = 4;  // GEN-BLOCK scope -- golden SPELLS this
    // w1  THE AWAY CELL: source text already equals golden's rendering
    assign w1 = {27'b0, chan[z].fld[0+:(8 - INNER)]};
    // w2  the same in the BASE half of a -: select
    assign w2 = {28'b0, chan[z].fld[(8 - INNER)-:3]};
    // w3  the same with a * operator
    assign w3 = {24'b0, chan[z].fld[0+:(2 * INNER)]};
    // w4  gen-block localparam beside a module localparam (v5 e1, restated)
    assign w4 = {27'b0, chan[z].fld[0+:(MOD - INNER)]};
    // w5  CONTROL: both leaves module-scope -- golden folds both
    assign w5 = {27'b0, chan[z].fld[0+:(MOD - 5)]};
    // w6  CONTROL: literal only, no parameter -- must be inert
    assign w6 = {27'b0, chan[z].fld[0+:(8 - 4)]};
    // w7  CONTROL: gen-block localparam ALONE as a bare width (not this law)
    assign w7 = {28'b0, chan[z].fld[0+:INNER]};
    // w8  CONTROL: the AWAY shape at MODULE scope (gate shut, depth 0)
    assign w8 = {23'b0, chan[0].fld[0+:(MOD - 0)]};
  end
  assign oz = w1^w2^w3^w4^w5^w6^w7^w8;
endmodule
