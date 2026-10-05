// § patFlatTernPickedLeafSpan250
// package struct parameters: a member read of a member read, a default: setter, a string-compare condition, imported into a module
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; logic [7:0] c; } s_t;
  localparam s_t D0 = '{a: 8'd10, default: 8'd7};
  localparam s_t D1 = '{a: D0.a, b: D0.c, c: ("x" == "x") ? D0.b : 8'd1};
  localparam s_t D2 = '{a: D1.a, b: (D1.b > 8'd3) ? D1.c : D0.a, c: 8'd0};
endpackage
module top(output logic [7:0] o1, o2, o3);
  import p::*;
  localparam s_t L = D2;
  assign o1 = L.a;
  assign o2 = L.b;
  assign o3 = D1.c;
endmodule
