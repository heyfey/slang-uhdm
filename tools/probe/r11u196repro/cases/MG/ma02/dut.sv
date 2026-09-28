// § modGenericClassListed196 § modGenericHandleBare196: the same with an initializer
module sub ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b = new;
endmodule
module top;
  sub v ();
endmodule
