// r10uvm94 arm a1 — the INDEXED-PART-SELECT BASE grid, inside hier_path names.
// MEASUREMENT-ONLY.  Deliberately NOT self-confirming: every base kind sits on a
// differently named member of a differently named holder, the widths differ per
// cell, the +:/-: directions alternate, and the cells that must NOT move
// (ref_obj / constant / operation bases, part_selects, bit_selects) sit beside
// the ones that must.
package qq94;
  parameter int PKW94 = 12;
  parameter int PKS94 = 5;
endpackage

class Holder94;
  bit [4095:0] store;
  bit [255:0]  minor;
  int          cursor;
  int          stride;
endclass

class Nest94;
  Holder94 deep;
  int      away;
  function new(); deep = new(); endfunction
endclass

typedef struct packed { logic [63:0] hi; logic [63:0] lo; } Pair94;

class Worker94;
  localparam int LOCW94 = 9;
  parameter  int PARW94 = 6;
  Holder94 hold;
  Nest94   nest;
  int      here;
  Pair94   pear;
  bit [31:0] tbl [0:3];

  function new(); hold = new(); nest = new(); endfunction

  // ---- c1..c8: the BASE kind grid, one member per kind, TRAIL element
  function void bases(int seed);
    logic [63:0] sink;
    int          walk;
    walk = seed;
    // c1  base = MEMBER hier_path, width = literal            (THE HEAD SHAPE)
    sink = hold.store[hold.cursor +: 32];
    // c2  base = MEMBER hier_path, width = literal, MINUS
    sink = hold.minor[hold.stride -: 8];
    // c3  base = TWO-DEEP hier_path
    sink = hold.store[nest.deep.cursor +: 16];
    // c4  base = plain LOCAL var (ref_obj)  -- must NOT move
    sink = hold.store[walk +: 24];
    // c5  base = LITERAL constant           -- must NOT move
    sink = hold.minor[19 +: 4];
    // c6  base = OPERATION                  -- must NOT move
    sink = hold.store[walk * 3 + 1 +: 40];
    // c7  base = PARAMETER read             -- must NOT move
    sink = hold.store[qq94::PKW94 +: 7];
    // c8  base = MEMBER hier_path, width = PARAMETER (folds)
    sink = hold.store[hold.cursor +: LOCW94];
  endfunction

  // ---- c9..c14: the WIDTH kind grid over a MEMBER hier_path base
  function void widths();
    logic [63:0] cup;
    // c9   width = $bits(<type>)
    cup = hold.store[hold.cursor +: $bits(int)];
    // c10  width = $bits(<var>)
    cup = hold.store[hold.stride +: $bits(here)];
    // c11  width = OPERATION
    cup = hold.store[hold.cursor +: (2 * 5)];
    // c12  width = package PARAMETER
    cup = hold.store[hold.cursor +: qq94::PKS94];
    // c13  width = class localparam, MINUS direction
    cup = hold.minor[hold.stride -: LOCW94];
    // c14  width = class parameter
    cup = hold.minor[hold.cursor +: PARW94];
  endfunction

  // ---- c15..c19: the CARRIER grid, all with a MEMBER hier_path base
  function void carriers(ref logic [63:0] out9);
    logic [63:0] box;
    int          got;
    // c15  LHS of a procedural assign
    hold.store[hold.cursor +: 20] = 20'h5a5a5;
    // c16  RHS through a CAST
    box = 64'(hold.store[hold.stride +: 11]);
    // c17  STREAMING-concatenation target (the UVM head's own carrier)
    { << { box }} = hold.store[hold.cursor +: 64];
    // c18  CALL argument
    got = takes(hold.minor[hold.stride +: 14]);
    // c19  by-ref out
    out9 = hold.store[nest.deep.stride -: 21];
  endfunction

  function int takes(logic [63:0] v9); return int'(v9[3:0]); endfunction

  // ---- c20..c24: the shapes that must be BYTE-IDENTICAL (the fence)
  function void fence();
    logic [63:0] keep;
    int          idx;
    idx = here;
    // c20  part_select with constant bounds over a dotted member
    keep = hold.store[95:64];
    // c21  part_select whose LEFT bound is an operation
    keep = hold.minor[LOCW94 - 1:0];
    // c22  bit_select over a dotted member, index a MEMBER hier_path
    keep = hold.store[hold.cursor];
    // c23  bit_select over a dotted member, index a local
    keep = hold.minor[idx];
    // c24  struct-member part select
    keep = pear.hi[31:16];
  endfunction

  // ---- c25..c26: a 3-deep path and a var_select carrier
  function void deeps();
    logic [63:0] cache;
    // c25  3-deep dotted path with a member-hier_path base
    cache = nest.deep.store[nest.deep.cursor +: 26];
    // c26  element-selected member with a trailing indexed range
    cache = tbl[2][here +: 6];
  endfunction
endclass

package fnpk94;
  import qq94::*;
  class Tiny94; bit [127:0] bag; int mark; endclass
  // ---- c27..c28: a PACKAGE function home
  function automatic int pkfn94(Tiny94 tt);
    logic [31:0] hold9;
    hold9 = tt.bag[tt.mark +: 18];      // c27  member base, literal width
    hold9 = tt.bag[7 +: 9];             // c28  constant base -- must NOT move
    return int'(hold9);
  endfunction
endpackage

module m94_top;
  import qq94::*;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } Two94;
  Two94 twin;
  logic [255:0] wide;
  int  spot;
  logic [63:0] grab;
  Worker94 wk;
  // ---- c29..c31: a MODULE home, always_comb and initial
  always_comb begin
    grab = wide[twin.a +: 12];          // c29  struct-member base (hier_path)
    grab = wide[spot +: 13];            // c30  plain local base -- must NOT move
  end
  initial begin
    wk = new();
    grab = wide[twin.b -: 15];          // c31  struct-member base, MINUS
    wk.bases(3); wk.widths(); wk.fence(); wk.deeps();
  end
endmodule
