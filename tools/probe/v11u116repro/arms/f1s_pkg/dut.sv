package pk;
  parameter int unsigned P = 32'h00000FFF;
endpackage
module dut import pk::*; ();
  logic [31:0] a [2];
  logic [31:0] o [2];
  logic [31:0] q [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & ~P;
    assign q[c] = a[c] & ~pk::P;
  end
endmodule
