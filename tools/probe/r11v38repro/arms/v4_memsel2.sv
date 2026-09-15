// v11u38 adversarial arm 4 — the member-select dim at harder homes.
typedef struct packed { logic [7:0] a; logic [7:0] b; } p2_t;
typedef struct packed { logic [15:0] w; } p1_t;

module v4_tp #(parameter type T = p2_t, parameter T PT = 16'h0503) ();
  logic tmem [PT.a];            // base declared by a TYPE PARAMETER
endmodule

module v4_loc ();
  typedef struct packed { logic [7:0] x; logic [7:0] y; } loc_t;  // MODULE-local typedef
  parameter loc_t LP = 16'h0604;
  logic lmem [LP.x];
  logic lmemy [LP.y];
endmodule

package v4_pkg;
  typedef struct packed { logic [7:0] m; logic [7:0] n; } pk_t;
  parameter pk_t PK = 16'h0302;
endpackage

module v4_imp import v4_pkg::*; ();
  logic pmem [PK.m];            // an IMPORTED package struct parameter (unqualified)
endmodule

module v4_top ();
  v4_tp u_a ();
  v4_tp #(.PT(16'h0907)) u_b ();
  v4_loc u_c ();
  v4_imp u_d ();
  v4_imp u_e ();
endmodule
