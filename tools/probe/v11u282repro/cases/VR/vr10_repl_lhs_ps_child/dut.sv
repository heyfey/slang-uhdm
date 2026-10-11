// § genCaReplCountInst282
module c #(parameter int W = 2) (input logic [7:0] e, output logic [7:0] q);
  if (W > 1) begin : gi
    assign q[3:0] = {W{e[1:0]}};
    assign q[7:4] = '0;
  end
endmodule
module top(input logic [7:0] e, output logic [7:0] q1, q2); c u1(.e(e), .q(q1)); c #(.W(2)) u2(.e(e), .q(q2)); endmodule
