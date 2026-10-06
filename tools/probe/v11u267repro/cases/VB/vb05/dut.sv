// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (output wire [7:0] o, output logic [7:0] q);
  logic [7:0] v;
  for (genvar i = 0; i < 1; i++) begin : ga
    if (1) begin : gb
      localparam int L = W * 2;
      assign o = {L{1'b1}};
      assign v = {L{1'b0}};
    end
  end
  assign q = v;
endmodule
module top(output wire [7:0] o, output logic [7:0] q, output wire [7:0] o2, output logic [7:0] q2);
  m u(.o(o), .q(q));
  m #(.W(4)) u2(.o(o2), .q(q2));
endmodule
