// § modportPortViewParamDef164 — modport port, named connection, no override
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
  modport mp(output data);
endinterface
module sub (my_iface.mp bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
