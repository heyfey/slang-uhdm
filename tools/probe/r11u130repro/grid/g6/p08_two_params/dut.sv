// § portViewParamDefName130
interface my_iface #(parameter W = 3, parameter int D = 2);
  logic [W-1:0] data [D];
endinterface
module sub (my_iface bus);
  assign bus.data[0] = '0;
endmodule
module top;
  my_iface #(.W(8), .D(4)) bus();
  sub u_sub(.bus(bus));
endmodule
