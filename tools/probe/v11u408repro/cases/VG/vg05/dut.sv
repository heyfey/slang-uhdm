// § genericClassNoDefaultListed408
class Foo #(int N);
  int x;
endclass
module test;
  Foo #(5) h;
  initial h = new;
endmodule
