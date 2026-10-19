// § ifacePortTdCastLogicTs405
interface ti; typedef struct packed { logic [3:0] a; logic [3:0] b; } T; endinterface
interface fi (ti types);
  typedef types.T T;
  logic [15:0] x;
  T y;
  always_comb y = T'(x);
endinterface
module top (output logic [7:0] o);
  ti t();
  fi f(t);
  assign o = f.y;
endmodule
