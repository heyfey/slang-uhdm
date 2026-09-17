// r11u64 GRID g3 — THE ROAD BOUNDARY.  Pass 60's § elabUnpStructOperandWidth61
// sizes an elaborated pattern operand AT ITS MEMBER on the PARAMETER road; this
// pass's law is the cont_assign road's answer to the same question.  Every cell
// here holds a SYMBOLIC-bound member and differs only in the road, so the two
// laws' territories are measured against each other rather than assumed.
package s64;
  typedef struct packed { logic [31:0] W; } cfg_t;
  function automatic cfg_t bld(); cfg_t c; c.W = 32'd6; return c; endfunction
  localparam cfg_t CFG = bld();
endpackage

// g01/g02 — pass 60's own road: an UNPACKED struct parameter, named setter and
// `default:` fill, on a symbolic-bound member
module h1 #(parameter int V = 3) (output logic [63:0] o);
  typedef struct { logic [V-1:0] a; logic [V-1:0] b; logic [7:0] c; } u_t;
  localparam u_t U1 = '{a: 3'd1, b: '0, c: '0};
  localparam u_t U2 = '{a: 3'd1, default: '0};
  assign o = 64'(U1.b) ^ 64'(U2.b);
endmodule

// g03 — a PACKED struct parameter, the same two forms
module h2 #(parameter int V = 3) (output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; logic [7:0] c; } t_t;
  localparam t_t P1 = '{a: 3'd1, b: '0, c: '0};
  localparam t_t P2 = '{a: 3'd1, default: '0};
  assign o = 64'(P1) ^ 64'(P2);
endmodule

// g04 — a struct NET Lhs (an explicit `wire`), not a variable
module h3 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  wire t_t vn;
  assign vn = '{a: pa[2:0], b: '0};
  assign o = 64'(vn);
endmodule

// g05 — the CORPUS WITNESS'S SHAPE: the bound reached through a package struct
// localparam's member, the struct handed on through a TYPE PARAMETER
module snk64 #(parameter type fu_t = logic) (input fu_t d, output logic [63:0] o);
  assign o = 64'(d);
endmodule
module h4 (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [s64::CFG.W-1:0] a; logic [s64::CFG.W-1:0] b;
  } t_t;
  t_t v;
  assign v = '{a: pa[5:0], b: '0};
  snk64 #(.fu_t(t_t)) c (.d(v), .o(o));
endmodule

// g06 — the same cont_assign inside an INTERFACE
interface ifc64 #(parameter int V = 3) (input logic [63:0] pa);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[2:0], b: '0};
endinterface
module h5 (input logic [63:0] pa, output logic [63:0] o);
  ifc64 #(.V(3)) i (.pa(pa));
  assign o = 64'(i.v);
endmodule

// g07 — an INSTANCE ARRAY: two elaborated copies of one written cont_assign
module h6a #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed { logic [V-1:0] a; logic [V-1:0] b; } t_t;
  t_t v;
  assign v = '{a: pa[2:0], b: '0};
  assign o = 64'(v);
endmodule
module h6 (input logic [63:0] pa, output logic [63:0] o);
  logic [63:0] t [0:1];
  h6a #(.V(3)) a [0:1] (.pa(pa), .o(t));
  assign o = t[0] ^ t[1];
endmodule

// g08 — TWO INSTANCES with DIFFERENT parameter values on one written pattern
module h7 (input logic [63:0] pa, output logic [63:0] o);
  logic [63:0] t1, t2;
  h6a #(.V(3)) x1 (.pa(pa), .o(t1));
  h6a #(.V(7)) x2 (.pa(pa), .o(t2));
  assign o = t1 ^ t2;
endmodule

module tb;
  logic [63:0] pa;
  logic [63:0] o1, o2, o3, o4, o5, o6, o7;
  h1 #(.V(3)) u1 (.o(o1));
  h2 #(.V(3)) u2 (.o(o2));
  h3 #(.V(3)) u3 (.pa(pa), .o(o3));
  h4 u4 (.pa(pa), .o(o4));
  h5 u5 (.pa(pa), .o(o5));
  h6 u6 (.pa(pa), .o(o6));
  h7 u7 (.pa(pa), .o(o7));
endmodule
