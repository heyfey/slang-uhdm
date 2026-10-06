// § hcSelIdxTsSkipsPort254 (an operation index over the imported parameter, a 2-D select with one imported index, a constant beside it)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module sub (input logic a, input logic b, input logic c);
endmodule
module top;
  import pk::*;
  logic [3:0] e;
  logic [3:0][1:0] m;
  sub u (.a(e[PMP_I + 1]), .b(m[2][PMP_D]), .c(m[PMP_D][0]));
endmodule
