// § portViewParamShared164 — two interface definitions with the same parameter name, ordered
interface ia #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
interface ib #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (ia.mp x, ib.mp y);
  assign x.data = '0;
  assign y.data = '1;
endmodule
module top;
  ia a0();
  ib b0();
  sub u0(a0, b0);
endmodule
