// § portViewParamShared164 — two ordered views, one overridden to the default value
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface b0();
  my_iface #(.W(3)) b1();
  sub u0(b0);
  sub u1(b1);
endmodule
