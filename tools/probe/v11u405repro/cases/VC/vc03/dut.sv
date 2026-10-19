// § ifacePortTdCastLogicTs405
interface ti; typedef logic [7:0] T; endinterface
interface fi (ti types);
  typedef types.T T;
  logic [15:0] x;
  logic [7:0] y;
  assign y = T'(x) + T'(x >> 8);
endinterface
module top (output logic [7:0] o);
  ti t();
  fi f(t);
  assign o = f.y;
endmodule
