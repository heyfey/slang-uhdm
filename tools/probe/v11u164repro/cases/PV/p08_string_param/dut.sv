// § modportPortViewParamDef164 — a string and an integer parameter behind an ordered modport connection
interface my_iface #(parameter string NAME = "x", parameter W = 2);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.NAME("abc")) b0();
  sub u0(b0);
endmodule
