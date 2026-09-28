// § modGenericClassListed196 § modGenericHandleBare196: a generic class extending a generic class of the home, a static method call through a specialization
module sub ();
  class base #(type T = int);
    T k;
  endclass
  class box #(type E = int) extends base #(E);
    static function int mk(); return 1; endfunction
  endclass
  box #(byte) b;
  int r;
  initial r = box#(byte)::mk();
endmodule
module top;
  sub v ();
endmodule
