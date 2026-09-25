// § modportPortViewParamDef164 — ordered modport connection, two parameters, one overridden
interface my_iface #(parameter W = 3, parameter D = 2);
  logic [W-1:0] data [D];
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  always_comb bus.data[0] = '0;
endmodule
module top;
  my_iface #(.W(4)) b0();
  sub u0(b0);
endmodule
