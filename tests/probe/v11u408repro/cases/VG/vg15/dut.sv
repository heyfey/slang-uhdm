// § genericClassNoDefaultListed408
class Foo #(int N);
  function int get();
    logic [N-1:0] t;
    t = '1;
    return t;
  endfunction
endclass
module test;
endmodule
