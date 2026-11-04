// § hcSelIdxTsSkipsPort254 (the port name a suffix of the signal name, a signal named like the instance, and a wildcard-imported index in a positional list)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module sub (input logic e, input logic ee);
endmodule
module top;
  import pk::*;
  logic [2:0] ee;
  logic [2:0] u;
  sub u1 (.e(ee[PMP_D]), .ee(u[PMP_I]));
  sub u2 (u[PMP_D], ee[PMP_D]);
endmodule
