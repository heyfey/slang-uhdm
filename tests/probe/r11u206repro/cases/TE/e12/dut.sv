// § tpCastUseBindsDefDefault206
module e12 #(parameter int W = 2, localparam type t = logic [W-1:0]) (input logic s, output logic [W-1:0] o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
