module dut ();
  parameter int unsigned P = 32'h00000FFF;
  function automatic logic [31:0] f(input logic [31:0] x); return x; endfunction
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = f(P) & a[c];
  end
endmodule
