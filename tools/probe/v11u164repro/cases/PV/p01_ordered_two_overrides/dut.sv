// § modportPortViewParamDef164 § portViewParamShared164 — ordered modport connections of two instances with different overrides
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(7)) b1();
  sub u0(b0);
  sub u1(b1);
endmodule
