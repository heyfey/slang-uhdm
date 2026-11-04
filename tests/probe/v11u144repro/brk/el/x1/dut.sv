// § elabCloneInstTreeUnstored144
module leaf #(parameter int W = 2)(input logic [W-1:0] a, output logic [W-1:0] y);
  assign y = ~a;
endmodule
module top(input logic [7:0] a, output logic [7:0] y);
  for (genvar i = 0; i < 2; i++) begin : G
    for (genvar j = 0; j < 2; j++) begin : H
      leaf #(.W(2)) u(.a(a[i*4+j*2 +: 2]), .y(y[i*4+j*2 +: 2]));
    end
  end
  logic [1:0] t;
  assign t = G[1].H[0].u.y;
endmodule
