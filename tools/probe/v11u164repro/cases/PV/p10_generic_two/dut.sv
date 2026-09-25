// § modportPortViewParamDef164 § portViewParamShared164 — two generic interface ports, ordered
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (interface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  sub u0(b0.mp);
  sub u1(b1.mp);
endmodule
