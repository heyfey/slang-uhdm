// § elabParamRefSignedTsUnlocated264
module sub #(parameter int N = 2) (output logic [31:0] o);
  localparam int A = 4;
  for (genvar i = 0; i < N; i++) begin : g
    localparam int B = A;
    localparam int C = i;
    localparam int D = B;
    if (i == 0) begin : h
      localparam int E = D;
      assign o[E] = 1'b1;
    end
    assign o[8 + C + B] = 1'b0;
  end
  if (N > 1) begin : ig
    localparam int F = A;
    assign o[20 + F] = 1'b1;
  end
  case (N)
    2: begin : cg
      localparam int K = A;
      assign o[24 + K] = 1'b0;
    end
    default: ;
  endcase
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
