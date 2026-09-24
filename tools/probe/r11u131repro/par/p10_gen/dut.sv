// § paramFoldParenSpan131
module top #(parameter N = 2) ();
  for (genvar i = 0; i < N; i++) begin : g
    localparam L = (i+1);
    logic [L:0] v;
  end
endmodule
