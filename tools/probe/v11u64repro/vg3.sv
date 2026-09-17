// v11u64 verifier grid 3 — the ARITHMETIC faces: every member kind the
// transcription claims to cover, summed beside a symbolic bound so the law
// must produce a POSITIVE width (a wrong transcription shows up as a wrong
// number, not as a decline).
module vc1 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // an UNPACKED array member with a symbolic dimension, in an unpacked struct
  typedef struct { logic [7:0] m0; logic [7:0] m1 [V]; } t;
  t s;
  assign s = '{m0: pa[7:0], m1: '{default: '0}};
  assign o = ^{s.m0, s.m1[0]};
endmodule

module vc2 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // the integer-atom kinds summed beside a symbolic bound (nested struct)
  typedef struct packed {
    logic [V-1:0] a; byte b; shortint c; longint d; int e; bit f;
  } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vc4 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // a nested struct holding a UNION, beside a symbolic bound
  typedef union packed { logic [V-1:0] u0; logic [V-1:0] u1; } u_t;
  typedef struct packed { logic [V-1:0] a; u_t u; logic [3:0] c; } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vc6 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // a STRING member beside a symbolic bound, in an unpacked struct
  typedef struct { logic [V-1:0] a; string sname; logic [7:0] c; } t;
  t s;
  assign s = '{a: '0, sname: "x", c: pa[7:0]};
  assign o = ^{s.a, s.c};
endmodule

module vc9 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // a nested struct whose SUM crosses 64 bits, with one symbolic bound
  typedef struct packed { logic [V-1:0] a; logic [99:0] b; } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vc10 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // a member WIDER than the transcription's 4096-bit guard, beside a symbolic
  typedef struct packed { logic [V-1:0] a; logic [8191:0] b; } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vc11 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // an ENUM member whose base width is symbolic, filled with '0 directly
  typedef enum logic [V-1:0] { Z0 = 0, Z1 = 1 } e_t;
  typedef struct packed { logic [7:0] m0; e_t m1; } t;
  t s;
  assign s = '{m0: pa, m1: e_t'('0)};
  assign o = ^s;
endmodule

module vc12 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  // a member that is a PACKED ARRAY of a nested struct with a symbolic bound
  typedef struct packed { logic [V-1:0] a; logic [7:0] b; } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t [1:0] m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vtb3;
  logic [63:0] pa;
  logic o1, o2, o4, o6, o9, o10, o11, o12;
  vc1  k1  (.pa(pa), .o(o1));
  vc2  k2  (.pa(pa), .o(o2));
  vc4  k4  (.pa(pa), .o(o4));
  vc6  k6  (.pa(pa), .o(o6));
  vc9  k9  (.pa(pa), .o(o9));
  vc10 k10 (.pa(pa), .o(o10));
  vc11 k11 (.pa(pa), .o(o11));
  vc12 k12 (.pa(pa), .o(o12));
endmodule
