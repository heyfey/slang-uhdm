// § modGenericClassListed196 § modGenericHandleBare196: two instances of the home, each specializing the class differently
module sub #(parameter int W = 1) ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
  box #(logic [W-1:0]) c;
endmodule
module top;
  sub #(2) v ();
  sub #(3) w ();
endmodule
