// § portViewParamShared164 — two reference-style port views of one definition (pass 130's def-named views)
interface my_iface #(parameter W = 3);
  logic [W-1:0] data;
endinterface
module sub (my_iface bus);
  always_comb bus.data = '0;
endmodule
module top;
  my_iface #(.W(5)) b0();
  my_iface #(.W(5)) b1();
  sub u0(.bus(b0));
  sub u1(.bus(b1));
endmodule
