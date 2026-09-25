// § portViewParamShared164 — one interface instance seen by two different receiving modules, ordered
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sa (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module sb (my_iface.mp bus);
endmodule
module top;
  my_iface #(.W(5)) b0();
  sa u0(b0);
  sb u1(b0);
endmodule
