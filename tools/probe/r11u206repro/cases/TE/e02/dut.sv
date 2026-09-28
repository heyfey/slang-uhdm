// § tpCastUseBindsDefDefault206
module e02 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : a
      assign x[i] = s ? t'(1) : t'(0);
    end else begin : b
      assign x[i] = t'(s);
    end
  end
  assign o = x[0];
endmodule
