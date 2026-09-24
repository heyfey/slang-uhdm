// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus);
  if (bus.W == 3) begin : g
    assign bus.data = '0;
  end
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
