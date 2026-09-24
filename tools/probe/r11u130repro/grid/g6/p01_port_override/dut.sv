// § portViewParamDefName130
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus);
  always_comb bus.data = '0;
endmodule
module top (output logic [21:0] out);
  my_iface #(.W(22)) bus();
  sub u_sub(.bus(bus));
  assign out = bus.data;
endmodule
