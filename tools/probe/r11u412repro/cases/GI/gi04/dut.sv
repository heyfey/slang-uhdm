// § genericIfacePosConnNoDouble412
interface my_iface;
  logic [2:0] data;
endinterface
module sub (interface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
