// § modGenericClassListed196 § modGenericHandleBare196: a module variable of a type-parameter specialization (r11u194 N1, Z/z01)
module sub ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
