// § modportPortViewParamDef164 — modport port first of two ordered connections (iface_param_port_width's shape)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus, input wire [bus.W-1:0] din);
  assign bus.data = din;
endmodule
module top (input [4:0] d);
  my_iface #(.W(5)) bus();
  sub u_sub(bus, d);
endmodule
