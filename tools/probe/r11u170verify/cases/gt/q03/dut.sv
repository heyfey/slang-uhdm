// § genTgtLhsLeafOwnName157
module top #(parameter int W = 2) (input logic a, output logic o, output logic [1:0] p);
  for (genvar i = 0; i < W; i++) begin : F
    if (1) begin : H wire z; end
  end
  if (1) begin : B wire [1:0] y; end
  assign F[0].H.z = a;
  assign F[1].H.z = ~a;
  assign B.y = {a, a};
  assign o = F[0].H.z ^ F[1].H.z;
  assign p = B.y;
endmodule
