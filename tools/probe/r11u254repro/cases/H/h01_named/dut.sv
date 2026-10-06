// § hcSelIdxTsSkipsPort254 (a high-conn bit-select indexed by an imported parameter: named and positional connections)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
  localparam int W = 2;
endpackage
module sub (input logic a, input logic b);
endmodule
module top;
  import pk::*;
  logic [2:0] e;
  sub u1 (.a(e[PMP_I]), .b(e[PMP_D]));
  sub u2 (e[PMP_D], e[PMP_I]);
endmodule
