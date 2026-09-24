// r11v75 xl — THE IMPORT HOME ON THE CLIMB.  The width walk climbs into the
// INSTANTIATING scope on a miss, and the new lookup is asked of every module
// body it reaches — including a PARENT that imports a package the child never
// names.  Does golden's `bindVariable` resize to that parent's imported
// signal?
package pk;
  logic [15:0] cw;
endpackage
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
  localparam cfg_t LIT = build(300);
endpackage

module child #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : gc
    logic [31:0] cw;  assign cw = CFG.n;   // only home: the PARENT's import
    logic [31:0] nw;  assign nw = CFG.n;   // no home anywhere: the control
  end
  assign o = gc.cw ^ gc.nw;
endmodule

module dut (output logic [31:0] o);
  import pk::*;                  // the PARENT imports it; the child does not
  child u (.o(o));
endmodule
