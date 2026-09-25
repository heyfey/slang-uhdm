// § modportPortViewParamDef164 — an interface localparam derived from the parameter
interface my_iface #(parameter W = 3);
  localparam W2 = W * 2;
  logic [W2-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  sub u0(b0);
endmodule
