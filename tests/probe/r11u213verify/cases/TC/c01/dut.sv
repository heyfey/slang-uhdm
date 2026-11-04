// § tpCastUseBindsDefDefault206
module c01 #(parameter int W = 3, parameter type t = logic [W-1:0]) (input logic s, input logic [1:0] k, output t o);
  t [7:0] x;
  if (W > 1) begin : gi
    for (genvar i = 0; i < 2; i++) begin : go
      for (genvar j = 0; j < 2; j++) begin : gn
        assign x[2*i+j] = (k[i] ^ s) ? t'(i + j) : t'(W - j);
      end
    end
  end
  assign o = x[1] ^ x[2];
endmodule
