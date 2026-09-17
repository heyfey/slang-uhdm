// r11u64 GRID g2 — THE NEIGHBOUR ROADS AND THE FENCE FACES.  Every cell holds a
// SYMBOLIC-bound member (the only member class this law can move) and varies the
// CARRIER, the Lhs kind, the scope and the pass-60 bail faces.  A cell that does
// not move is as much a measurement as one that does.
package r64;
  localparam int PW = 5;
endpackage

// f01 — the PARAMETER road (pass 60's own): a struct parameter whose pattern
// initializer names a symbolic-bound member, both as a NAMED setter and through
// a `default:` fill.  The `default:` half of the flatten carries NO
// `patFlatAdjust` fence, so this cell decides whether the law reaches it.
module f1 #(parameter int V = 3) (output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; logic [7:0] c; } t_t;
  localparam t_t P1 = '{a: 3'd1, b: '0, c: '0};
  localparam t_t P2 = '{a: 3'd1, default: '0};
  assign o = 64'(P1) ^ 64'(P2);
endmodule

// f02 — an ALWAYS_COMB assignment (a procedural carrier, not a cont_assign)
module f2 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  always_comb v = '{a: pa[2:0], b: '0};
  assign o = 64'(v);
endmodule

// f03 — an EXPLICIT CAST around the whole pattern (pass 55's cast fence face)
module f3 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = t_t'('{a: pa[2:0], b: '0});
  assign o = 64'(v);
endmodule

// f04 — a SIGNED symbolic member (pass 60's signed bail face)
module f4 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic signed [V-1:0] a; logic signed [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[2:0], b: '0};
  assign o = 64'(v);
endmodule

// f05 — a member WIDER THAN 64 BITS with a symbolic bound (pass 60's >64 face)
module f5 #(parameter int V = 65) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [3:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[3:0], b: '0};
  assign o = 64'(v);
endmodule

// f06 — the SAME cont_assign inside a GENERATE block
module f6 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  logic [63:0] t;
  generate
    for (genvar g = 0; g < 1; g++) begin : gb
      t_t v;
      assign v = '{a: pa[2:0], b: '0};
      assign t = 64'(v);
    end
  endgenerate
  assign o = t;
endmodule

// f07 — a PORT CONNECTION actual written as a pattern (the r10earl107 road,
// which this pass does not touch) and a MODULE-LOCAL struct parameter passed on
module snk #(parameter int V = 3) (input logic [63:0] d, output logic [63:0] o);
  assign o = d;
endmodule
module f7 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[2:0], b: '0};
  snk #(.V(V)) s (.d(64'(v)), .o(o));
endmodule

// f08 — an UNPACKED struct's DECLARATION INITIALIZER (the carrier the landed
// `patFlatAdjust` fence keeps out of the named half)
module f8 #(parameter int V = 3) (output logic [63:0] o);
  typedef struct { logic [V-1:0] a; logic [V-1:0] b; } u_t;
  u_t dv = '{a: 3'd1, b: '0};
  assign o = 64'(dv.a);
endmodule

// f09 — a module that is NEVER INSTANTIATED: the DEF view alone
module f9 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[2:0], b: '0};
  assign o = 64'(v);
endmodule

// f10 — a PACKAGE-localparam bound (a bound Surelog folds) beside a module one,
// in ONE struct: the two classes must part company inside a single pattern
module f10 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [3:0] a; logic [V-1:0] b; logic [r64::PW-1:0] c;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], b: '0, c: '0};
  assign o = 64'(v);
endmodule

module tb;
  logic [63:0] pa;
  logic [63:0] o1, o2, o3, o4, o5, o6, o7, o8, o10;
  f1 #(.V(3))  u1  (.o(o1));
  f2 #(.V(3))  u2  (.pa(pa), .o(o2));
  f3 #(.V(3))  u3  (.pa(pa), .o(o3));
  f4 #(.V(3))  u4  (.pa(pa), .o(o4));
  f5 #(.V(65)) u5  (.pa(pa), .o(o5));
  f6 #(.V(3))  u6  (.pa(pa), .o(o6));
  f7 #(.V(3))  u7  (.pa(pa), .o(o7));
  f8 #(.V(3))  u8  (.o(o8));
  f10 #(.V(3)) u10 (.pa(pa), .o(o10));
endmodule
