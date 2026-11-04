// § modGenericClassListed196 § modGenericHandleBare196: a property of another module class
module sub ();
  class box #(type E = int);
    E v;
  endclass
  class holder;
    box #(byte) m;
  endclass
  holder h;
endmodule
module top;
  sub v ();
endmodule
