// § tpCastUseBindsDefDefault206
interface ifc #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s);
  t [1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      assign x[i] = s ? t'(i) : t'(j);
    end
  end
endinterface
module c07 #(parameter type t = logic [3:0]) (input logic s, output logic [1:0] o, output t p);
  ifc u (.s(s));
  t [1:0] y;
  for (genvar k = 0; k < 2; k++) begin : g
    assign y[k] = u.x[k] == 0 ? t'(k) : t'(3);
  end
  assign o = u.x[0];
  assign p = y[1];
endmodule
