// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus);
  always_comb bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
