// § modGenericClassListed196: a module generic class whose type parameter has no default, specialized by a handle
module sub ();
  class box #(type E);
    E v;
  endclass
  box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
