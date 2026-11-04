// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  localparam int D = W * 2;
  logic [D-1:0] data;
endinterface
module sub (my_iface bus);
  always_comb bus.data = '0;
endmodule
module top;
  my_iface #(.W(4)) bus();
  sub u_sub(.bus(bus));
endmodule
