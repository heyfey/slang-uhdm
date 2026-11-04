// § ovrParamBoundOpSelName198: an override chain through a middle instance (top -> mid #(Q+1) -> ch #(P)), the bound operation in the leaf's if-generate
module ch #(parameter int unsigned P = 2) (input logic [31:0] w, output logic [2:0] y);
  if (P > 0) begin : g
    assign y = w[P+2:P];
  end
endmodule
module mid #(parameter int unsigned Q = 1) (input logic [31:0] w, output logic [2:0] y);
  ch #(.P(Q+1)) c (.w(w), .y(y));
endmodule
module top (input logic [31:0] w, output logic [2:0] y);
  mid #(.Q(4)) m (.w(w), .y(y));
endmodule
