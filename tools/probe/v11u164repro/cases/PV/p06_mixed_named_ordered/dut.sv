// § modportPortViewParamDef164 § portViewParamShared164 — one definition seen through a named in-scope view and an ordered view
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  sub u0(.bus(b0));
  sub u1(b1);
endmodule
