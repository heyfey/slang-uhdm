// § modportPortViewParamDef164 — a wildcard connection of a modport port
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) bus();
  sub u0(.*);
endmodule
