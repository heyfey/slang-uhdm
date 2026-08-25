// r10v91 arm 6 — the remaining hier_path FACES and homes from the brief.
package p6;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } sm_t;
  typedef struct packed { sm_t inner; logic [3:0] c; } nst_t;
  typedef logic [11:0] wa_t [2];
  parameter sm_t PS = '{a: 8'hAB, b: 4'h5};
  parameter logic [11:0] PW = 12'd9;
endpackage

interface ifc6;
  logic [11:0]  sig;
  p6::sm_t      st;
  logic [11:0]  marr [2];
  logic [11:0]  b1 [2];
  p6::wa_t      b2;
  modport mp (input sig, input st, output marr);
  assign b1 = '{sig, 12'd1};     // cont_assign INSIDE an interface, inline target
  assign b2 = '{sig, 12'd1};     // typedef'd target inside an interface (KEEP)
endinterface

module usemp6 (ifc6.mp p, input logic [11:0] d, output logic [11:0] o);
  logic [11:0] m1 [2];
  assign m1 = '{p.sig, d};       // MODPORT member as operand 0
  logic [11:0] m2 [2];
  assign m2 = '{p.st.a, d};      // modport STRUCT member
  assign p.marr = '{d, 12'd2};   // target reached THROUGH a modport
  assign o = m1[0]^m2[0];
endmodule

module deep6 #(parameter int W = 12) (input logic [W-1:0] d, output logic [W-1:0] o);
  p6::nst_t nn; assign nn = p6::nst_t'(d);
  logic [W-1:0] r1 [2];
  assign r1 = '{p6::PS.a, d};                // PACKAGE PARAMETER MEMBER as operand 0
  logic [W-1:0] r2 [2];
  assign r2 = '{p6::PW, d};                  // package parameter (plain)
  logic [W-1:0] r3 [3];
  assign r3 = '{nn.inner.b, nn.inner.a, d};  // NESTED member, 3 elements
  wire  [W-1:0] wr [2];
  assign wr = '{d, {W{1'b1}}};               // a WIRE (net) array target
  assign o = r1[0]^r2[0]^r3[0]^wr[0];
endmodule

module mid6 (input logic [11:0] d, output logic [11:0] o, ifc6 itf);
  logic [11:0] x0, x1, x2;
  deep6 #(.W(12)) d0 (.d(d),    .o(x0));
  deep6 #(.W(12)) d1 (.d(d^1),  .o(x1));
  deep6 #(.W(8))  d2 (.d(d[7:0]), .o());
  usemp6 up (.p(itf.mp), .d(d), .o(x2));
  assign o = x0^x1^x2;
endmodule

module v6_faces91 (input logic [11:0] din, output logic [11:0] q);
  ifc6 itf();
  assign itf.sig = din;
  assign itf.st  = p6::sm_t'(din);
  logic [11:0] r;
  mid6 m (.d(din), .o(r), .itf(itf));
  // a 3-deep chain read as operand 0
  logic [11:0] dp [2];
  assign dp = '{m.d0.nn.inner.a, din};
  assign q = r ^ dp[0] ^ itf.b1[0] ^ itf.b2[0] ^ itf.marr[0];
endmodule
