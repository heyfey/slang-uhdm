// § genCaReplCountInst282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [3:0] z);
  if (1) begin : gi
    logic [3:0] t;
    assign t = {W{e[1:0]}};
    assign z = t;
  end
endmodule
