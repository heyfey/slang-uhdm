// § extScopedParamBaseName412
package pk;
  class B #(type T = int); T v; endclass
  class C; endclass
endpackage
module test;
  class D extends pk::B #(logic [3:0]); endclass
  class E extends pk::C; endclass
  class F extends pk::B; endclass
  D d;
endmodule
