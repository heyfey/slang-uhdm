module dut #(parameter int unsigned P = 32'h0000_0FFF, parameter int unsigned Q = P) ();
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & Q;
  end
endmodule
