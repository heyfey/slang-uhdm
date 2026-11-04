// § genericClassNoDefaultListed408
class Foo #(int N);
  int x;
endclass
class Bar extends Foo#(3);
  int y;
endclass
module test;
  Bar h;
  initial h = new;
endmodule
