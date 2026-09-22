// VERIFIER arm z8 — THE CONTEXT AXIS WIDENED.  `m4_ctx86` measured the
// `default:` road and a packed array with a `'d` hop only.  Here the same roads
// carry an `'o` hop, a REPLICATION, an UNPACKED array and a NESTED struct
// member, because each is a different expansion and the law is claimed
// context-free.
package z8p;
  localparam PD = 16'd5;
  localparam PO = 16'o17;
  typedef struct packed { logic [23:0] x; logic [23:0] y; } inner;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; inner n;
  } t;
  typedef struct packed { logic [23:0] p; logic [23:0] q; logic [23:0] r; } t3;
endpackage
module z8_ctx86;
  localparam MD = 16'd5;
  localparam MO = 16'o17;
  localparam z8p::t   ZN = '{bail: 8'hxA, a: MD, b: MO, n: '{x: MD, y: MO}};
  localparam z8p::t3  ZDF = '{default: MO};
  localparam z8p::t3  ZDD = '{default: MD};
  localparam z8p::t3  ZRP = '{3{MO}};
  localparam z8p::t3  ZAR = '{MD, MO, z8p::PO};
  localparam z8p::t3  ZPK = '{p: z8p::PD, q: z8p::PO, r: MD};
  z8_sink #(.R(ZN)) s1();
  z8_s3 #(.R(ZDF)) s2();
  z8_s3 #(.R(ZRP)) s3();
  z8_s3 #(.R(ZAR)) s4();
endmodule
module z8_sink #(parameter z8p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
module z8_s3 #(parameter z8p::t3 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.p;
endmodule
