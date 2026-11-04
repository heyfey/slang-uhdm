// § extScopedParamBaseName412
package pk;
  class Bar #(int x = 1, int y = 2);
  endclass
endpackage
class Foo extends pk::Bar #(.x(3), .y(4));
endclass
class Foo2 extends pk::Bar;
endclass
class Foo3 extends pk::Bar #(5);
endclass
module top;
  Foo f; Foo2 f2; Foo3 f3;
endmodule
