// § genericClassNoDefaultListed408
class Outer;
  class Inner #(int N);
    int x;
  endclass
  int y;
endclass
module test;
  Outer h;
  initial h = new;
endmodule
