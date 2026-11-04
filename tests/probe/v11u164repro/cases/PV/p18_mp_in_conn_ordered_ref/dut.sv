// § modportPortViewParamDef164 — a reference-style port connected with a modport expression, ordered
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  sub u0(b0.mp);
endmodule
