// § hcSelIdxTsSkipsPort254 (the connection in a for-generate block, and in instances at depth two and three)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module leaf (input logic a);
endmodule
module mid (input logic [2:0] x);
  import pk::*;
  leaf l (.a(x[PMP_D]));
endmodule
module top;
  import pk::*;
  logic [2:0] e;
  mid m (.x(e));
  for (genvar k = 0; k < 2; k++) begin : gk
    leaf g (.a(e[PMP_I]));
  end
endmodule
