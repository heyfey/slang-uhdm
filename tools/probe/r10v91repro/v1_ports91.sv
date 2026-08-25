// r10v91 arm 1 — PORT High_conn patterns onto UNPACKED-ARRAY ports, and
// net-decl-assign patterns.  These reach the r10earl91 site through
// ModuleEmit's High_conn re-emit (reemitting=true) and the net-decl-assign
// nested-pattern re-emit, NOT through writeCont_assign — so if golden sizes
// operand 0 there, the law regresses them.
package p1;
  typedef logic [11:0] wd_t;
  typedef logic [11:0] wa_t [2];
  typedef struct packed { logic [7:0] a; logic [3:0] b; } sm_t;
endpackage

module sink_arr (input logic [11:0] a [2], output logic [11:0] o);
  assign o = a[0] ^ a[1];
endmodule

module sink_arr1 (input logic [11:0] a [1], output logic [11:0] o);
  assign o = a[0];
endmodule

module sink_ta (input p1::wa_t a, output logic [11:0] o);
  assign o = a[0] ^ a[1];
endmodule

module sink_sc (input logic s [2], output logic o);
  assign o = s[0] ^ s[1];
endmodule

module sink_2d (input logic [11:0] a [2][2], output logic [11:0] o);
  assign o = a[0][0] ^ a[1][1];
endmodule

module sink_sarr (input p1::sm_t a [2], output logic [11:0] o);
  assign o = {a[0].a, a[0].b} ^ {a[1].a, a[1].b};
endmodule

module v1_ports91 (input logic [11:0] din, input logic sb, output logic [11:0] q);
  logic [11:0] v12;
  logic [11:0] arr12 [2];
  p1::wa_t     ta1;
  logic [11:0] o1, o2, o3, o5, o6;
  logic        o4;

  assign v12 = din;
  assign arr12 = '{din, din};
  assign ta1   = '{din, din};

  // A1: High_conn pattern onto an INLINE unpacked-array port.
  sink_arr  u1 (.a('{v12, din}),          .o(o1));
  // A2: High_conn pattern onto a TYPEDEF'd unpacked-array port.
  sink_ta   u2 (.a('{v12, din}),          .o(o2));
  // A3: High_conn pattern, ONE element, inline unpacked array.
  sink_arr1 u3 (.a('{v12}),               .o(o3));
  // A4: scalar-element inline unpacked array port.
  sink_sc   u4 (.s('{sb, sb}),            .o(o4));
  // A5: 2-D inline unpacked array port, NESTED pattern.
  sink_2d   u5 (.a('{'{v12,din},'{din,v12}}), .o(o5));
  // A6: unpacked array of PACKED STRUCT port.
  sink_sarr u6 (.a('{p1::sm_t'(din), p1::sm_t'(v12)}), .o(o6));

  // B: NET-DECL-ASSIGN with a pattern (inline unpacked array target).
  wire  [11:0] nd1 [2] = '{v12, din};
  logic [11:0] nd2 [2][2] = '{'{v12,din},'{din,v12}};
  p1::wa_t     nd3 = '{v12, din};

  assign q = o1 ^ o2 ^ o3 ^ o5 ^ o6 ^ {11'd0,o4} ^ nd1[0] ^ nd2[0][0] ^ nd3[1] ^ arr12[0] ^ ta1[0];
endmodule
