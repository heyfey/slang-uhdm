// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (interface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface #(.W(6)) bus();
  sub u_sub(.bus(bus));
endmodule
