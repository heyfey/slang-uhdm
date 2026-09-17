// v11u64 verifier grid 1 — faces the implementer's g1/g2/g3 did not hold.
// Every pattern's operand[0] is a plain net reference, so Surelog's
// instance-aware walk (stamp B) stops there and the rest of the vector carries
// stamp A (the no-instance flatten) alone.
package vq;
  parameter int PP = 5;                      // a package PARAMETER, not a localparam
  typedef struct packed { logic [31:0] W; logic [31:0] T; } cfg_t;
  function automatic cfg_t mk(); cfg_t c; c.W = 32'd9; c.T = 32'd4; return c; endfunction
  localparam cfg_t CFG = mk();
endpackage

// A1 — the bound references a PACKAGE PARAMETER.
module va1 (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [vq::PP-1:0] m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

// A2 — the bound is an OPERATION over a reference: 2*V-1.
// A3 — a REVERSED range [0:V-1].
// A4 — the bound is the bare reference V.
module va2 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed {
    logic [7:0]     m0;
    logic [2*V-1:0] m2;
    logic [0:V-1]   m3;
    logic [V:0]     m4;
  } t;
  t s;
  assign s = '{m0: pa, m2: '0, m3: '0, m4: '0};
  assign o = ^s;
endmodule

// A5 — an ENUM member whose base has a symbolic width.
// A9 — a BIT member with a symbolic width.
module va5 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef enum logic [V-1:0] { E0 = 0, E1 = 1 } e_t;
  typedef struct packed { logic [7:0] m0; e_t m5; bit [V-1:0] m9; } t;
  t s;
  assign s = '{m0: pa, m5: e_t'(0), m9: '0};
  assign o = ^s;
endmodule

// A6 — a NESTED struct member mixing a symbolic and a fixed bound (the sum).
// A8 — TWO symbolic dimensions on one member.
module va6 #(parameter int V = 3, parameter int W = 5) (input logic [63:0] pa,
                                                        output logic o);
  typedef struct packed { logic [V-1:0] i0; logic [7:0] i1; } inner_t;
  typedef struct packed { logic [7:0] m0; inner_t m6; logic [V-1:0][W-1:0] m8; } t;
  t s;
  assign s = '{m0: pa, m6: '0, m8: '0};
  assign o = ^s;
endmodule

// A7 — a UNION member (packed union of a symbolic and a fixed arm).
module va7 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef union packed { logic [V-1:0] u0; logic [V-1:0] u1; } u_t;
  typedef struct packed { logic [7:0] m0; u_t m7; } t;
  t s;
  assign s = '{m0: pa, m7: '0};
  assign o = ^s;
endmodule

// A10 — a POSITIONAL (untagged) pattern with the same members.
module va10 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t s;
  assign s = '{pa, '0};
  assign o = ^s;
endmodule

// A13 — the bound holds a SYSTEM FUNCTION CALL over a symbolic argument.
module va13 #(parameter int V = 9) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [$clog2(V)-1:0] m13; } t;
  t s;
  assign s = '{m0: pa, m13: '0};
  assign o = ^s;
endmodule

// A15 — the witness's own shape (a hier_path bound) but on a PACKAGE typedef.
module va15 (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [vq::CFG.W-1:0] m15; } t;
  t s;
  assign s = '{m0: pa, m15: '0};
  assign o = ^s;
endmodule

// A16 — the Lhs is a FIELD SELECT of a struct variable.
module va16 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] n0; logic [V-1:0] n1; } sub_t;
  typedef struct packed { sub_t sub; logic [3:0] tail; } t;
  t s;
  assign s.sub = '{n0: pa, n1: '0};
  assign s.tail = 4'h0;
  assign o = ^s;
endmodule

// A17 — the pattern sits in a TERNARY arm on the cont_assign road.
module va17 #(parameter int V = 3) (input logic [63:0] pa, input logic c,
                                    output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t s;
  assign s = c ? '{m0: pa, m1: '0} : '{m0: pa, m1: '1};
  assign o = ^s;
endmodule

// A11 — an UNPACKED-struct DECLARATION INITIALIZER with a `default:` fill
// (our unfenced half) on a symbolic member.
module va11 #(parameter int V = 3) (output logic o);
  typedef struct { logic [V-1:0] d1; logic [7:0] d2; } dt;
  dt dv = '{default: '0};
  assign o = ^{dv.d1, dv.d2};
endmodule

// A18 — the `'1` fill on a symbolic member, and a `default:'1` beside it.
module va18 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; logic [V-1:0] m2; } t;
  t s;
  assign s = '{m0: pa, m1: '1, default: '1};
  assign o = ^s;
endmodule

// A19 — an UNPACKED struct carrying a REAL beside a symbolic member.
module va19 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct { logic [7:0] m0; real r; logic [V-1:0] m1; } t;
  t s;
  assign s = '{m0: pa[7:0], r: 1.0, m1: '0};
  assign o = ^{s.m0, s.m1};
endmodule

module vtb;
  logic [63:0] pa;
  logic c;
  logic o1, o2, o5, o6, o7, o10, o13, o15, o16, o17, o11, o18, o19;
  logic o2b, o6b;
  va1  i1  (.pa(pa), .o(o1));
  va2  i2  (.pa(pa), .o(o2));
  va2 #(.V(7)) i2b (.pa(pa), .o(o2b));
  va5  i5  (.pa(pa), .o(o5));
  va6  i6  (.pa(pa), .o(o6));
  va6 #(.V(6), .W(2)) i6b (.pa(pa), .o(o6b));
  va7  i7  (.pa(pa), .o(o7));
  va10 i10 (.pa(pa), .o(o10));
  va13 i13 (.pa(pa), .o(o13));
  va15 i15 (.pa(pa), .o(o15));
  va16 i16 (.pa(pa), .o(o16));
  va17 i17 (.pa(pa), .c(c), .o(o17));
  va11 i11 (.o(o11));
  va18 i18 (.pa(pa), .o(o18));
  va19 i19 (.pa(pa), .o(o19));
endmodule
