// § hcSelIdxTsSkipsPort254 (the module own localparam index e[LP])
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
  localparam int W = 2;
endpackage
typedef struct packed { logic [2:0] f; } s_t;
module sub (input logic a);
endmodule
module top #(parameter int HP = 1);
  import pk::*;
  localparam int LP = 0;
  logic [3:0] e;
  logic [2:0][1:0] m;
  s_t s;
  sub u (.a(e[LP]));
endmodule
