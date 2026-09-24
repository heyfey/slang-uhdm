// § paramFoldParenSpan131
module top (output logic [3:0] o);
  localparam int N = (2 + 2);
  for (genvar i = 0; i < N; i++) begin : g
    assign o[i] = 1'b0;
  end
endmodule
