// § hcSelIdxTsSkipsPort254 (a part select with an imported bound, a struct member select, and an index under a ternary)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
typedef struct packed { logic [2:0] f; } s_t;
module sub (input logic [1:0] a, input logic b, input logic c);
endmodule
module top (input logic s);
  import pk::*;
  logic [2:0] e;
  s_t st;
  sub u (.a(e[PMP_D:PMP_I]), .b(st.f[PMP_D]), .c(s ? e[PMP_I] : e[PMP_D]));
endmodule
