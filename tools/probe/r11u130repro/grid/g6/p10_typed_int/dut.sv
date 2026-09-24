// § portViewParamDefName130
interface my_iface #(parameter int W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) bus();
  sub u_sub(.bus(bus));
endmodule
