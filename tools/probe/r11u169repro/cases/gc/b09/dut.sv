// § genCaFoldTsChainNamed169
package pk;
  parameter int Q = 6;
endpackage
module dut ();
  import pk::*;
  parameter int P = Q;
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & P & pk::Q;
  end
endmodule
