// § modportPortViewParamDef164 — the receiving module has its own parameter; ordered connection
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub #(parameter W = 9) (my_iface.mp bus, output [W-1:0] o);
  assign bus.data = '0;
  assign o = '0;
endmodule
module top (output [3:0] o);
  my_iface #(.W(5)) b0();
  sub #(4) u0(b0, o);
endmodule
