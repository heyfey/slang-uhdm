// § genCaReplParentBoundLhs267
module m #(parameter int W = 3) (output logic [W-1:0] o, output logic [7:0] p);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : h
      assign o = {W{1'b0}};
    end else begin : h2
      assign p = {2{4'b1010}};
    end
  end
endmodule
module top(output logic [2:0] o, output logic [7:0] p, output logic [3:0] o2, output logic [7:0] p2);
  m u0(.o(o), .p(p));
  m #(.W(4)) u1(.o(o2), .p(p2));
endmodule
