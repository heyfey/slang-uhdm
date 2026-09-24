module dut ();
  parameter int unsigned P = 32'h00000FFF;
  parameter int unsigned R = P + 1;
  localparam int unsigned S = 32'hF0;
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & R & S & P[7:0];
  end
endmodule
