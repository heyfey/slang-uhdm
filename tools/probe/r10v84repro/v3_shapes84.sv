// r10v84 arm v3 — SHAPES.  hier_path DEPTH 2/3/4, an instance ARRAY, a
// POSITIONAL (ordered) connection, the bare `-:` form, a ternary and a
// concatenation around the select, and the same select in an instance-
// PARAMETER actual position.
package sv84;
  parameter int SW = 8;
endpackage

module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

function automatic logic [7:0] ufv84(input logic [7:0] x);
  return x;
endfunction

module shapes84;
  import sv84::*;
  typedef struct packed { logic [31:0] q; } l3_t;
  typedef struct packed { l3_t c;         } l2_t;
  typedef struct packed { l2_t b;         } l1_t;
  l1_t  deep;
  l3_t  shallow;
  logic [31:0] flat;
  localparam int Db = 2;

  sinkv84 #(.W(SW)) d2 (.a(shallow.q[Db +: SW]));          // hier_path depth 2
  sinkv84 #(.W(SW)) d3 (.a(deep.b.c.q[Db +: SW]));         // hier_path depth 4

  sinkv84 #(.W(SW)) arr84 [1:0] (.a(deep.b.c.q[Db +: SW]));// instance ARRAY
  sinkv84 #(SW)     u_pos (deep.b.c.q[Db +: SW]);          // POSITIONAL conn

  sinkv84 #(.W(SW)) u_dn (.a(deep.b.c.q[Db+SW -: SW]));    // -: with an op base
  sinkv84 #(.W(2))  u_dn2 (.a(deep.b.c.q[Db -: 2]));       // -: with a BARE base

  sinkv84 #(.W(SW)) u_tern (.a(Db == 2 ? deep.b.c.q[Db +: SW] : 8'd0));
  sinkv84 #(.W(SW)) u_cat  (.a({deep.b.c.q[Db +: 4], 4'd0}));

  // NESTED calls: a system call inside a user call and the reverse
  sinkv84 #(.W(SW)) u_su (.a(ufv84($unsigned(deep.b.c.q[Db +: SW]))));
  sinkv84 #(.W(SW)) u_us (.a($unsigned(ufv84(deep.b.c.q[Db +: SW]))));
endmodule
