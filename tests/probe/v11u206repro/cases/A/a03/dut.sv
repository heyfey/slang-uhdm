// § tpCastUseBindsDefDefault206
module a03 #(parameter int W = 3) (input logic s, output logic [W-1:0] o);
  localparam type t = logic [W-1:0];
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
