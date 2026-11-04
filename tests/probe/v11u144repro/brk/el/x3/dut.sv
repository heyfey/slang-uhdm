// § elabCloneInstTreeUnstored144
module sub #(parameter int N = 2)(input logic [N-1:0] d, output logic o);
  for (genvar k = 0; k < N; k++) begin : S
    logic t;
    if (k == 0) begin : F
      assign t = d[k];
    end else begin : R
      assign t = d[k] ^ S[k-1].t;
    end
  end
  assign o = S[N-1].t;
endmodule
module top(input logic [3:0] d, output logic o1, o2);
  sub #(.N(2)) u1(.d(d[1:0]), .o(o1));
  sub #(.N(4)) u2(.d(d), .o(o2));
endmodule
