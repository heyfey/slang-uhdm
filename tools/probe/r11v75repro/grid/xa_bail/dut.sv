// r11v75 xa — LAW D's OVER-FIRE FACE.  The caMemSel record is taken at
// emission unconditionally; the DRAIN decides later whether the fold happens.
// § caGenScopeFoldedLhsNoOwnBind75 reads the RECORD (`foldRec75`), so a cell
// the drain DECLINES loses its own-local Lhs actual although its Rhs never
// folded.  Every row below is a gen-scope cont_assign onto an own gen-local
// with NO namesake anywhere; only the base's shape varies.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
  // A SIGNED int member: the drain's recorded decline.
  typedef struct packed { int s; logic [7:0] t; } sgn_t;
  function automatic sgn_t sbuild(int x);
    sgn_t c; c.s = x; c.t = 8'h3C; return c;
  endfunction
  // A member the builder never assigns: an x-bearing slice.
  function automatic cfg_t xbuild(int unsigned x);
    cfg_t c; c.t = 8'h0F; return c;
  endfunction
  // A PACKAGE-level base.
  localparam cfg_t PCFG = build(300);
endpackage

module dut (output logic [31:0] o);
  localparam p::cfg_t CFG = p::build(256);
  localparam p::sgn_t SG  = p::sbuild(7);
  localparam p::cfg_t XG  = p::xbuild(5);
  for (genvar i = 0; i < 1; i = i + 1) begin : gb
    logic [31:0] ok_n;   assign ok_n  = CFG.n;      // control: the fold works
    logic [31:0] sgn_s;  assign sgn_s = SG.s;       // SIGNED int member
    logic [31:0] xun_n;  assign xun_n = XG.n;       // x-bearing member
    logic [31:0] pk_n;   assign pk_n  = p::PCFG.n;  // PACKAGE-level base
  end
  assign o = gb[0].ok_n ^ gb[0].sgn_s ^ gb[0].xun_n ^ gb[0].pk_n;
endmodule
