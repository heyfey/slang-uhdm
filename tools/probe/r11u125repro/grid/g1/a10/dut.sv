// § genvarParamFile125
interface ifc;
  logic [3:0] v;
  for (genvar i = 0; i < 4; i++) begin : g
    assign v[i] = 1'b0;
  end
endinterface
module top(output o);
  ifc u();
  assign o = u.v[0];
endmodule
