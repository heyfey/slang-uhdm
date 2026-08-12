// r10earl32 VERIFIER arm v4 — CONTAINERS AND INITIALISERS THE GRID SKIPS.
//
// a3_ctx measured the DEF-view generate process (g3 bare / g4 qualified) and a
// NESTED generate scope (g5) — but not the ELABORATED generate body, not an
// if-generate, not an INTERFACE and not a PROGRAM.  a5_init measured five
// non-reducing shapes and five reducing ones — but not a TERNARY init, not a
// $clog2 init, not a cross-package init chain, not an unsized `'1`, and not an
// `int unsigned` parameter.  Every one of those is a cell the shipped gate
// answers by fall-through, so every one of them is a place the law can be wrong
// without any corpus test noticing.
package p4;
  localparam logic [11:0] P    = 12'h380;
  localparam logic [11:0] PT   = (1) ? 12'h381 : 12'h382;   // TERNARY init
  localparam int          PC   = $clog2(300);               // SYS-FUNC init
  localparam logic [11:0] PU   = '1;                        // UNSIZED '1
  localparam int unsigned PI   = 7;                         // int unsigned
  localparam logic [11:0] PX   = P + 12'h1;                 // param-of-own-pkg
endpackage

package p4b;
  localparam logic [11:0] QB = p4::P;                       // CROSS-package chain
endpackage

module m4gen (output logic [31:0] o1, o2, o3, o4);
  import p4::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  // ELABORATED for-generate body — qualified and bare
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    logic [31:0] w;
    assign w = mf(p4::P) + mf(P);
  end
  // if-generate
  if (1) begin : iblk
    logic [31:0] w;
    assign w = mf(p4::P);
  end
  assign o1 = gblk[0].w;
  assign o2 = gblk[1].w;
  assign o3 = iblk.w;
  assign o4 = 32'h0;
endmodule

interface i4 (input logic clk);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  logic [31:0] iv;
  assign iv = mf(p4::P);                                    // INSIDE an INTERFACE
endinterface

module m4init (output logic [31:0] a, b, c, d, e, f);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  function automatic logic [31:0] mi(int v);          return v;          endfunction
  assign a = mf(p4::PT);                                    // ternary init
  assign b = mi(p4::PC);                                    // $clog2 init
  assign c = mf(p4::PU);                                    // '1
  assign d = mi(p4::PI);                                    // int unsigned
  assign e = mf(p4::PX);                                    // param-of-param
  assign f = mf(p4b::QB);                                   // cross-package chain
endmodule

module m4top (input logic clk);
  logic [31:0] g1,g2,g3,g4,h1,h2,h3,h4,h5,h6;
  m4gen  ug (.o1(g1), .o2(g2), .o3(g3), .o4(g4));
  m4init ui (.a(h1), .b(h2), .c(h3), .d(h4), .e(h5), .f(h6));
  i4     ii (.clk(clk));
endmodule
