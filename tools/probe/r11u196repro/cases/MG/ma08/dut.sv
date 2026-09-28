// § modGenericClassListed196 § modGenericHandleBare196: control: a plain module class
module sub ();
  class plain;
    int v;
  endclass
  plain b;
endmodule
module top;
  sub v ();
endmodule
