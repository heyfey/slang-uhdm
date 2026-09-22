// VERIFIER arm z1 — DECLARED TYPES ON THE HOP.  The law maps a `'d` leaf to
// INT: and an `'o` leaf to UINT: from the LITERAL's base alone.  If the
// producer's stored Value type is decided by the PARAMETER's declared type
// rather than the literal's base, a `bit`/`byte`/`int unsigned` hop is golden
// UINT: where the law writes INT: — a MOVED-WRONG.  Eight declared types, one
// MODULE pattern, 24-bit members, operand 0 the guaranteed bail.
package z1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module z1_decl86;
  localparam bit [15:0]   ZBB = 16'd5;
  localparam byte         ZBY = 8'd5;
  localparam int          ZIN = 16'd5;
  localparam int unsigned ZIU = 16'd5;
  localparam integer      ZIG = 16'd5;
  localparam shortint     ZSH = 16'd5;
  localparam bit [15:0]   ZBO = 16'o5;
  localparam logic signed [15:0] ZLS = 16'd5;
  localparam z1p::t Z = '{bail: 8'hxA, a: ZBB, b: ZBY, c: ZIN, d: ZIU,
                          e: ZIG, f: ZSH, g: ZBO};
  localparam z1p::t Z2 = '{bail: 8'hxA, a: ZLS, b: ZBB, c: ZBO, d: ZIN,
                           e: ZIU, f: ZIG, g: ZSH};
  z1_sink #(.R(Z)) s1();
  z1_sink #(.R(Z2)) s2();
endmodule
module z1_sink #(parameter z1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
