// § modportPortViewParamDef164 § portViewParamShared164 — named outer, ordered inner pass-through, plus a direct ordered view
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module leaf (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module mid (my_iface.mp bus);
  leaf l(bus);
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  mid m(.bus(b0));
  leaf k(b1);
endmodule
