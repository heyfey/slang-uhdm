// r11u62 grid g4 -- THE OVERRIDE ACTUAL'S OWN ENCODING.
// One holder module per (formal kind), instantiated once per ACTUAL KIND, so
// every cell is a distinct elaborated param_assign Rhs.  Both views are read:
// the DEF listing rows are `work@<mod>.<P>`, the elaborated ones
// `work@tb62.<inst>.<P>`.
package r62;
  typedef struct packed { logic [31:0] XLEN; logic [31:0] TID; } cfg_t;
  function automatic cfg_t build_config();
    cfg_t c; c.XLEN = 32'd64; c.TID = 32'd3; return c;
  endfunction
  localparam cfg_t CFG = build_config();
  localparam int unsigned OPW = 64 - 8;          // an OPERATION-valued scalar
endpackage

// ---- struct-typed formal, one holder per actual kind ------------------
module s01 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s02 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s03 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s04 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s05 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s06 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s07 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s08 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s09 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s10 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s11 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s12 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s13 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
// depth 2: the RE-PASS.  s14 receives an actual and passes its own P down.
module s15 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  assign o = P.TID[0];
endmodule
module s14 #(parameter r62::cfg_t P = r62::build_config()) (output logic o);
  s15 #(.P(P)) g (.o(o));
endmodule
// a struct formal with NO default (pure override)
module s16 #(parameter r62::cfg_t P = r62::cfg_t'(0)) (output logic o);
  assign o = P.TID[0];
endmodule

// ---- SCALAR formals: the control half -----------------------------------
module k01 #(parameter int Q = 0) (output logic o);        assign o = Q[0]; endmodule
module k02 #(parameter int Q = 0) (output logic o);        assign o = Q[0]; endmodule
module k03 #(parameter logic [63:0] Q = 0) (output logic o); assign o = Q[0]; endmodule
module k04 #(parameter Q = 0) (output logic o);            assign o = Q[0]; endmodule
module k05 #(parameter Q = 0) (output logic o);            assign o = Q[0]; endmodule
module k06 #(parameter int Q = 0) (output logic o);        assign o = Q[0]; endmodule
module k07 #(parameter int Q = 0) (output logic o);        assign o = Q[0]; endmodule
// a packed-ARRAY (non-struct complex) formal
module k08 #(parameter logic [1:0][31:0] Q = '0) (output logic o); assign o = Q[0][0]; endmodule
module k09 #(parameter logic [1:0][31:0] Q = '0) (output logic o); assign o = Q[0][0]; endmodule

module tb62;
  logic o01,o02,o03,o04,o05,o06,o07,o08,o09,o10,o11,o12,o13,o14,o16;
  logic p01,p02,p03,p04,p05,p06,p07,p08,p09;
  // --- struct formal x actual kind ---
  s01 #(.P(r62::build_config()))                u01 (.o(o01)); // BUILDER CALL
  s02 #(.P(64'h0000_0020_0000_0005))            u02 (.o(o02)); // HEX literal
  s03 #(.P(64'b0000000000000000000000000100000000000000000000000000000000000111)) u03 (.o(o03)); // BIN literal
  s04 #(.P(64'o0000000004000000000007))         u04 (.o(o04)); // OCT literal
  s05 #(.P(64'd274877906951))                   u05 (.o(o05)); // 'd BASED literal
  s06 #(.P(274877906953))                       u06 (.o(o06)); // BARE decimal
  s07 #(.P(r62::CFG))                           u07 (.o(o07)); // BARE REF to the assembled package lp
  s08 #(.P(r62::CFG | 64'h1))                   u08 (.o(o08)); // EXPRESSION over it
  s09 #(.P({32'd64, 32'd9}))                    u09 (.o(o09)); // CONCAT
  s10 #(.P(r62::cfg_t'(64'h0000_0040_0000_000B))) u10 (.o(o10)); // CAST of a hex literal
  s11 #(.P('{XLEN:32'd64, TID:32'd13}))         u11 (.o(o11)); // ASSIGNMENT PATTERN
  s12 #(.P(32'h15))                             u12 (.o(o12)); // NARROW hex literal
  s13 #(.P('h17))                               u13 (.o(o13)); // UNSIZED hex literal
  s14 #(.P(64'h0000_0080_0000_0019))            u14 (.o(o14)); // depth-2 RE-PASS
  s16 #(.P(64'h0000_0100_0000_001B))            u16 (.o(o16)); // no builder default

  // --- scalar formals: the control half ---
  k01 #(.Q(32'h20))       v01 (.o(p01));   // int formal, HEX actual
  k02 #(.Q(32'd33))       v02 (.o(p02));   // int formal, 'd actual
  k03 #(.Q(64'h21))       v03 (.o(p03));   // logic[63:0] formal, HEX actual
  k04 #(.Q(32'h22))       v04 (.o(p04));   // untyped formal, HEX actual
  k05 #(.Q(35))           v05 (.o(p05));   // untyped formal, BARE decimal
  k06 #(.Q(r62::OPW))     v06 (.o(p06));   // int formal, OPERATION-valued ref
  k07 #(.Q(36))           v07 (.o(p07));   // int formal, BARE decimal
  k08 #(.Q({32'd64, 32'd37}))          v08 (.o(p08));  // packed array formal, CONCAT
  k09 #(.Q(64'h0000_0200_0000_0027))   v09 (.o(p09));  // packed array formal, HEX
endmodule
