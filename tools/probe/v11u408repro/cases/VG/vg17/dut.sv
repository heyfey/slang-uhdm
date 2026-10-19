// § genericClassNoDefaultListed408
class Foo #(int N);
  rand int x;
  constraint c1 { x < N; }
endclass
module test;
endmodule
