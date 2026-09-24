// § portViewParamDefName130
interface my_iface #(parameter logic [7:0] W = 8'hff, parameter N = 2 + 3);
  logic [N-1:0] data;
endinterface
module sub (my_iface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
