// § hcSelIdxTsSkipsPort254 (an imported-index select inside a binary operation and a unary operation in the connection)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module sub (input logic a, input logic b);
endmodule
module top;
  import pk::*;
  logic [2:0] e;
  sub u (.a(e[PMP_I] & e[PMP_D]), .b(~e[PMP_D]));
endmodule
