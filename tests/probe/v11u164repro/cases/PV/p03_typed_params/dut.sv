// § modportPortViewParamDef164 — typed interface parameters behind an ordered modport connection
interface my_iface #(parameter int W = 3, parameter logic [3:0] M = 4'h5);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(6)) b0();
  sub u0(b0);
endmodule
