// r11v89 break arm v2 — LAW B's VALUE EDGES.  The relaxed fence now lets a
// MODULE-homed hop wider than 64 bits reach the `INT:`/`UINT:` rewrite.  What
// happens at 2^63, at 2^64-1, past 2^64, and with more octal digits than a
// word holds?  A wide PORT parameter (overridden and not) beside them.
package x2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module x2_wide89;
  localparam logic [95:0] W1 = 96'd9223372036854775807;   // 2^63-1, fits int64
  localparam logic [95:0] W2 = 96'd9223372036854775808;   // 2^63, not int64
  localparam logic [95:0] W3 = 96'd18446744073709551615;  // 2^64-1
  localparam logic [95:0] W4 = 96'd18446744073709551616;  // 2^64, past the word
  localparam logic [95:0] W5 = 96'o7777777777777777777777; // 66 octal bits
  localparam logic [65:0] W6 = 66'd0;                     // zero, past 64
  localparam logic [95:0] W7 = 96'd12;
  localparam x2p::t A = '{bail: 8'hxA, a: W1, b: W2, c: W3, d: W4,
                          e: W5, f: W6, g: W7};
  x2_sink #(.R(A)) s1();
  x2_mid #(.PW(96'd21)) m1();
  x2_mid                m2();
endmodule
module x2_mid #(parameter logic [95:0] PW = 96'd12,
                parameter logic [95:0] PD = 96'd33) ();
  localparam x2p::t B = '{bail: 8'hxA, a: PW, b: PD, c: PW, d: PD,
                          e: PW, f: PD, g: PW};
  x2_sink #(.R(B)) s2();
endmodule
module x2_sink #(parameter x2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
