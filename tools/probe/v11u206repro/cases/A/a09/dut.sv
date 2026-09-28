// § tpCastUseBindsDefDefault206
interface ifc #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
endinterface
module a09 (input logic s, output logic [1:0] o);
  ifc u (.s(s));
  assign o = u.x[0];
endmodule
