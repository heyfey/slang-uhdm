// § extScopedParamBaseName412
package pk;
  class Bar #(type T = int);
    T v;
  endclass
  class Baz extends pk::Bar #(logic [3:0]);
  endclass
endpackage
module top;
  pk::Baz b;
endmodule
