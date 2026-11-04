// § modGenericClassListed196 § modGenericHandleBare196: a module generic class beside a package generic class of the same name
package pk;
  class box #(type E = int);
    E v;
  endclass
endpackage
module sub ();
  class box #(type E = int);
    E w;
  endclass
  box #(byte) a;
  pk::box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
