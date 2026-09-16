// r11u49 arm b2 -- the NESTED-AGGREGATE-MEMBER fence, packed outer vs unpacked
// outer, each scoped-read.  a4 accidentally made both outers UNPACKED; this
// arm separates them.
package p;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } inner_p_t;
  typedef struct        { int unsigned m; int unsigned n; } inner_u_t;
  typedef struct packed { inner_p_t ip; logic [7:0] k; } pnest_t;  // PACKED outer
  typedef struct        { inner_p_t ip; int unsigned k; } unest_t;  // UNPACKED outer
  typedef struct        { inner_u_t iu; int unsigned k; } unestu_t; // UNPACKED outer, unpacked inner
  typedef struct packed { logic [7:0] a; logic [7:0] b; } flatp_t;  // control
  typedef struct        { int unsigned a; int unsigned b; } flatu_t; // control
  localparam pnest_t  PN = '{ip: '{x:4'h1, y:4'h2}, k: 8'd5};
  localparam unest_t  UN = '{ip: '{x:4'h1, y:4'h2}, k: 6};
  localparam unestu_t UU = '{iu: '{m:1, n:2}, k: 7};
  localparam flatp_t  FP = '{a:8'd1, b:8'd2};
  localparam flatu_t  FU = '{a:1, b:2};
endpackage
module b2 (output logic [31:0] o);
  assign o = p::PN.k + p::UN.k + p::UU.k + p::FP.b + p::FU.b;
endmodule
