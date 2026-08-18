// r10earl69 arm a1 — the ELAB gen-scope cont_assign hier_path NAME grid.
// Golden = Surelog.  Every cell is a hier_path inside a cont_assign that lives
// in a GENERATE FOR block, so the emitted copy is an ELAB gen-scope object.
package p69;
  parameter int PP  = 7;          // package parameter, literal init
  parameter int PW  = 8;          // package parameter, literal init
  parameter int PC  = 3 + 1;      // package parameter, COMPUTED init
endpackage

typedef struct packed {
  logic [31:0] addr;
  logic [7:0]  dat;
} rec69_t;

module m69 import p69::*; ();
  localparam int LP  = 7;         // module-local localparam, literal
  localparam int LW  = 8;
  localparam int LC  = 2 * 4;     // module-local localparam, computed
  parameter  int MP  = 7;         // module parameter

  rec69_t read_buf [4];
  rec69_t marr [4][4];
  logic [63:0] flat [4];
  logic [31:0] w;
  logic [7:0]  o [64];
  logic        ob [64];

  for (genvar i = 0; i < 2; i++) begin : g1
    // A: the head's own shape — PACKAGE params as ips bounds, genvar base index
    assign o[0+i] = read_buf[i].addr[PP+:PW];
    // B: MODULE-LOCAL localparam bounds
    assign o[1] = read_buf[i].addr[LP+:LW];
    // C: MODULE parameter bounds
    assign o[2] = read_buf[i].addr[MP+:PW];
    // D: computed-init package parameter
    assign o[3] = read_buf[i].addr[PC+:PW];
    // E: computed-init local localparam
    assign o[4] = read_buf[i].addr[LC+:PW];
    // F: SIMPLE range with package-param bounds
    assign o[5] = read_buf[i].addr[PW:PP];
    // G: SIMPLE range with LOCAL localparam bounds
    assign o[6] = read_buf[i].addr[LW:LP];
    // H: literal bounds (control)
    assign o[7] = read_buf[i].addr[7+:8];
    // I: GENVAR as the ips BASE
    assign o[8] = read_buf[i].addr[i+:8];
    // J: GENVAR-derived operation as the ips base
    assign o[9] = read_buf[i].addr[i+1+:8];
    // K: package-param plus genvar as the ips base
    assign o[10] = read_buf[i].addr[PP+i+:8];
    // L: a plain member read, no trailing select
    assign o[11] = read_buf[i].dat;
    // M: member bit-select with a PACKAGE param index
    assign ob[0] = read_buf[i].addr[PP];
    // N: member bit-select with a LOCAL localparam index
    assign ob[1] = read_buf[i].addr[LP];
    // O: member bit-select with the GENVAR index
    assign ob[2] = read_buf[i].addr[i];
    // P: nested genvar loop -> two genvar indexes
    // Q: base index is a package param, trailing is the genvar
    assign ob[3] = read_buf[PP-7].addr[i];
    // R: base index is an operation on the genvar
    assign ob[4] = read_buf[i+1-1].addr[PP];
    // S: two-dim base select
    assign o[12] = marr[i][1].addr[PP+:PW];
    // T: no base select at all — plain dotted member with a param ips
    assign o[13] = read_buf[0].addr[PP+:PW];
  end

  for (genvar i = 0; i < 2; i++) begin : g2
    for (genvar j = 0; j < 2; j++) begin : g3
      // U: nested genvars, one in the base index and one as an ips base
      assign o[14] = read_buf[i].addr[j+:8];
      // V: both genvars in the name
      assign ob[5] = read_buf[i].addr[j];
      // W: package param bounds two blocks deep
      assign o[15] = read_buf[i].addr[PP+:PW];
    end
  end

  // X: the SAME shapes OUTSIDE a generate block (module-body cont_assign)
  assign o[16] = read_buf[0].addr[PP+:PW];
  assign o[17] = read_buf[0].addr[LP+:LW];
endmodule
