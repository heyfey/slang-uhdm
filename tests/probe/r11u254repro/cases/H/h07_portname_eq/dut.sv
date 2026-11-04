// § hcSelIdxTsSkipsPort254 (the port and the selected net share a name; a second port)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
  localparam int W = 2;
endpackage
module sub (input logic e, input logic u);
endmodule
module top;
  import pk::*;
  logic [2:0] e;
  logic [2:0] uu;
  sub u (.e(e[PMP_I]), .u(uu[PMP_D]));
endmodule
