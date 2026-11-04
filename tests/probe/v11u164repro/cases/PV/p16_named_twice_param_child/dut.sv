// § modportPortViewParamDef164 — named in-scope connections into two specialisations of the receiver (control)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub #(parameter K = 1) (my_iface.mp bus);
  assign bus.data = K;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  sub #(1) u0(.bus(b0));
  sub #(2) u1(.bus(b1));
endmodule
