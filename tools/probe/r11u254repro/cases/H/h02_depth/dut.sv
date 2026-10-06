// § hcSelIdxTsSkipsPort254 (instance depths 1 to 3, the select in a child's definition)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
  localparam int W = 2;
endpackage
module leaf (input logic a);
endmodule
module mid import pk::*; (input logic [2:0] e);
  leaf l (.a(e[PMP_D]));
endmodule
module mid2 (input logic [2:0] e);
  mid m (.e(e));
endmodule
module top;
  logic [2:0] e;
  mid2 u (.e(e));
endmodule
