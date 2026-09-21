// r11v75 xc — LAW B's WIDTH HALF CAN SUPPRESS, not only add.  The width walk
// (`genCaSubstAdjustW71`) CLIMBS into the instantiating scope on a miss; the
// new import lookup RETURNS at the first scope whose import items carry the
// name, whatever KIND that symbol is.  A package PARAMETER or TYPEDEF of that
// name therefore answers 0 and the walk never reaches the outer signal the
// pristine binary resizes to.
package pk;
  localparam int zz = 7;        // a package PARAMETER named zz (not a signal)
  typedef logic [3:0] tt;       // a package TYPEDEF named tt
  function automatic int ff(int x); return x; endfunction  // a package FUNCTION
endpackage
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
  localparam cfg_t LIT = build(300);
endpackage

module child #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  import pk::*;                 // wildcard import of NON-SIGNAL names
  if (1) begin : gz
    logic [31:0] zz;  assign zz = CFG.n;   // outer namesake zz is 8 bits
    logic [31:0] tt;  assign tt = CFG.n;   // outer namesake tt is 12 bits
    logic [31:0] ff;  assign ff = CFG.n;   // outer namesake ff is 4 bits
    logic [31:0] nn;  assign nn = CFG.n;   // no namesake anywhere: control
  end
  assign o = gz.zz ^ gz.tt ^ gz.ff ^ gz.nn;
endmodule

module dut (output logic [31:0] o);
  logic [7:0]  zz;              // PARENT-instance signal, 8 bits
  logic [11:0] tt;              // PARENT-instance signal, 12 bits
  logic [3:0]  ff;              // PARENT-instance signal, 4 bits
  child u (.o(o));
endmodule
