// § ifacePortTdCastLogicTs405
interface ti; typedef logic [7:0] T; endinterface
module m (ti types, input logic [15:0] x, output logic [7:0] o);
  typedef types.T T;
  assign o = T'(x);
endmodule
module top (input logic [15:0] x, output logic [7:0] o);
  ti t();
  m u(t, x, o);
endmodule
