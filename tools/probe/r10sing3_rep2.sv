package pk;
  typedef struct packed { logic p; logic n; } st;
  parameter st ST_DEF = '{p: 1'b0, n: 1'b1};
endpackage

module child(input [11:0] e, input [11:0] f, input [11:0] g,
             input [11:0] h, output int x);
  assign x = int'(e);
endmodule

module top(output int o);
  import pk::*;
  parameter pk::st LOCST = '{p: 1'b1, n: 1'b0};
  parameter pk::st ALIAS = pk::ST_DEF;
  logic [1:0] w;
  child u(
    .e({6{pk::ST_DEF}}),   // pkg param, struct, scoped
    .f({6{LOCST}}),        // local param, struct
    .g({6{ST_DEF}}),       // pkg param, struct, bare via import
    .h({6{ALIAS}}),        // local param aliasing a pkg struct param
    .x(o));
endmodule
