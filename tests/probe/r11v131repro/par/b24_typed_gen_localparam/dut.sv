// § paramFoldParenSpan131
module top (output logic [31:0] o);
  parameter int N = 3;
  if (N > 1) begin : g
    localparam int L = (N * 2);
    assign o = L;
  end
endmodule
