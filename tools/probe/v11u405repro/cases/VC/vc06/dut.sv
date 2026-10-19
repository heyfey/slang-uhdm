// § ifacePortTdCastLogicTs405
interface ti; typedef logic [7:0] T; endinterface
interface fi (ti types);
  typedef types.T T;
  logic [15:0] x;
  logic [7:0] y;
  if (1) begin : g
    assign y = T'(x);
  end
endinterface
module top (output logic [7:0] o);
  ti t();
  fi f(t);
  assign o = f.y;
endmodule
