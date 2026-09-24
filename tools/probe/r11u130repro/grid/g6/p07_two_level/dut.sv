// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module leaf (my_iface bus);
  assign bus.data = '0;
endmodule
module mid (my_iface bus);
  leaf l(.bus(bus));
endmodule
module top;
  my_iface #(.W(7)) bus();
  mid m(.bus(bus));
endmodule
