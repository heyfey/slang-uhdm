// § genericClassNoDefaultListed408
package pk;
  class Foo #(int N);
    int x;
  endclass
  Foo #(6) g;
endpackage
module test;
  pk::Foo #(5) h;
  initial h = new;
endmodule
