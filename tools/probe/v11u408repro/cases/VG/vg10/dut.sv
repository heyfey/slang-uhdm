// § genericClassNoDefaultListed408
package pk;
  class Foo #(int N);
    static function int get(); return N; endfunction
  endclass
endpackage
module test;
  int x;
  initial x = pk::Foo#(2)::get();
endmodule
