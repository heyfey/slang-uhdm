// r11v94 BREAK arm x1 — LAW A's SYNTHESIZED TYPESPEC on the shapes the
// implementer's q1/q2/q7 do NOT hold: a hex/octal leaf under an implicit
// SIGNED declaration (where the size face declines but the sign face fires —
// a half-golden cell if the decode is wrong), a 64-bit literal with no
// dimension, a MULTI packed dimension, a dimension WIDER than the reader,
// and the two cells where LAW A crosses LAW B (an implicit signing keyword
// over a NEGATIVE initializer).
package x1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed            AH   = 8'hA;
  localparam signed            AO   = 8'o17;
  localparam signed            A64  = 64'd5;
  localparam signed [63:0]     A64D = 8'd5;
  localparam        [15:0]     APD2 = 8'd5;
  localparam signed [1:0][7:0] AM   = 16'd5;
  localparam unsigned          AUN  = -3;
  localparam signed            ASN  = -3;
endpackage
module x1_synedge94v;
  localparam logic [7:0] C1 = x1p::AH;
  localparam logic [7:0] C2 = x1p::AO;
  localparam logic [7:0] C3 = x1p::A64;
  localparam logic [7:0] C4 = x1p::A64D;
  localparam logic [7:0] C5 = x1p::APD2;
  localparam logic [7:0] C6 = x1p::AM;
  localparam logic [7:0] C7 = x1p::AUN;
  localparam logic [7:0] C8 = x1p::ASN;
  localparam x1p::t A = '{bail: 8'hxA, a: C1, b: C2, c: C3, d: C4,
                          e: C5, f: C6, g: C7};
  localparam x1p::t B = '{bail: 8'hxA, a: C8, b: C1, c: C2, d: C3,
                          e: C4, f: C5, g: C6};
  x1_sink #(.R(A)) s1();
  x1_sink #(.R(B)) s2();
endmodule
module x1_sink #(parameter x1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
