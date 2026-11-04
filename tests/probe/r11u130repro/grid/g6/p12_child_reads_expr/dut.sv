// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus, output logic [7:0] o);
  assign o = bus.W;
endmodule
module top(output logic [7:0] o);
  my_iface bus();
  sub u_sub(.bus(bus), .o(o));
endmodule
