// § bareDecUnderscoreDropped181 (v11u181 break: parameter defaults with separators read by a generate loop and a localparam expression; an instance override)
module sub #(parameter int N = 1_6, parameter int M = N * 1_0)(output logic [N-1:0] o);
  assign o = M[N-1:0];
endmodule
module top(output logic [15:0] a, output logic [7:0] b);
  localparam int K = 2_0 - 1_2;
  sub u1(.o(a));
  sub #(.N(K), .M(1_000)) u2(.o(b));
  for (genvar g = 0; g < 1_0; g += 5) begin : G
    logic [K-1:0] t;
    assign t = g + 1_0;
  end
endmodule
