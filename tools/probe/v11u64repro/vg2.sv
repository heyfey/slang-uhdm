// v11u64 verifier grid 2 — the MOVED-WRONG hunt: shapes where the two
// producers' BOUND TREES could disagree (ours symbolic where golden folded, or
// the reverse), plus the carriers the law's gate can still reach.
package wq;
  parameter  int PW = 5;
  localparam int LW = 6;
  function automatic int f(int x); return x + 2; endfunction
  localparam int FW = f(3);
  typedef struct packed { logic [7:0] pa0; logic [LW-1:0] pb; } pk_t;   // B1
  typedef struct packed { logic [7:0] pa0; logic [PW-1:0] pc; } pp_t;   // B2
  typedef struct packed { logic [7:0] pa0; logic [FW-1:0] pd; } pf_t;   // B3
endpackage

// B1/B2/B3 — struct typedefs declared IN A PACKAGE, bounds from a package
// localparam, a package parameter, and a package constant-function localparam.
module vb1 (input logic [63:0] pa, output logic o);
  wq::pk_t s1; wq::pp_t s2; wq::pf_t s3;
  assign s1 = '{pa0: pa, pb: '0};
  assign s2 = '{pa0: pa, pc: '0};
  assign s3 = '{pa0: pa, pd: '0};
  assign o = ^{s1, s2, s3};
endmodule

// B4 — a TYPEDEF'd member type with a symbolic width, and a PACKED ARRAY of it.
module vb4 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef logic [V-1:0] w_t;
  typedef struct packed { logic [7:0] m0; w_t m1; w_t [1:0] m2; } t;
  t s;
  assign s = '{m0: pa, m1: '0, m2: '0};
  assign o = ^s;
endmodule

// B5 — a typedef inside a GENERATE block, bound derived from the GENVAR.
module vb5 (input logic [63:0] pa, output logic o);
  logic [1:0] r;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    typedef struct packed { logic [7:0] m0; logic [gi+1:0] m1; } t;
    t s;
    assign s = '{m0: pa, m1: '0};
    assign r[gi] = ^s;
  end
  assign o = ^r;
endmodule

// B6 — a `default:` fill with NO unvaluable operand: the instance-aware walk
// covers the WHOLE vector, so stamp (A)'s answer must be overwritten.
module vb6 #(parameter int V = 3) (output logic o);
  typedef struct packed { logic [V-1:0] m0; logic [V-1:0] m1; } t;
  t s;
  assign s = '{default: '0};
  assign o = ^s;
endmodule

// B7 — the `'x` and `'z` fills on a symbolic member.
module vb7 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; logic [V-1:0] m2; } t;
  t s;
  assign s = '{m0: pa, m1: 'x, m2: 'z};
  assign o = ^s;
endmodule

// B8 — a PACKED-struct DECLARATION INITIALIZER with a `default:` fill (the
// half our emitter leaves unfenced).
module vb8 #(parameter int V = 3) (output logic o);
  typedef struct packed { logic [V-1:0] d1; logic [7:0] d2; } dt;
  dt dv = '{default: '0};
  assign o = ^dv;
endmodule

// B9 — the Lhs is an ELEMENT of an unpacked array of structs.
module vb9 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t arr [2];
  assign arr[0] = '{m0: pa, m1: '0};
  assign arr[1] = '{m0: pa, m1: '0};
  assign o = ^{arr[0], arr[1]};
endmodule

// B10 — a struct declared in an INTERFACE, assigned inside it.
interface vif #(parameter int V = 3) (input logic [63:0] pa);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
endinterface

module vb10 (input logic [63:0] pa, output logic o);
  vif #(.V(4)) u (.pa(pa));
  assign o = ^u.s;
endmodule

// B11 — the members are written OUT OF DECLARATION ORDER with a valuable
// leading operand, so the instance-aware walk covers both.
module vb11 #(parameter int V = 3) (output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t s;
  assign s = '{m1: '0, m0: 8'd1};
  assign o = ^s;
endmodule

// B12 — a member whose bound calls a NON-system constant function of a
// parameter.
module vb12 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [wq::f(V)-1:0] m1; } t;
  t s;
  assign s = '{m0: pa, m1: '0};
  assign o = ^s;
endmodule

module vtb2;
  logic [63:0] pa;
  logic ob1, ob4, ob5, ob6, ob7, ob8, ob9, ob10, ob11, ob12, ob4b;
  vb1  j1  (.pa(pa), .o(ob1));
  vb4  j4  (.pa(pa), .o(ob4));
  vb4 #(.V(9)) j4b (.pa(pa), .o(ob4b));
  vb5  j5  (.pa(pa), .o(ob5));
  vb6  j6  (.o(ob6));
  vb7  j7  (.pa(pa), .o(ob7));
  vb8  j8  (.o(ob8));
  vb9  j9  (.pa(pa), .o(ob9));
  vb10 j10 (.pa(pa), .o(ob10));
  vb11 j11 (.o(ob11));
  vb12 j12 (.pa(pa), .o(ob12));
endmodule
