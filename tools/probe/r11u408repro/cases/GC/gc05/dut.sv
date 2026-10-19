// § genericClassNoDefaultListed408
class Foo #(int N);
  logic [N-1:0] v;
endclass
module test;
  Foo #(4) h;
  initial h = new;
endmodule
