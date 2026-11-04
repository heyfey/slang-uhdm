// § genericClassNoDefaultListed408
class Foo #(int N, int P = 2);
  int x;
  function int get(); return x + P; endfunction
endclass
module test;
endmodule
