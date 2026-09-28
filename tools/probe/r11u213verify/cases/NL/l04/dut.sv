// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (a class declared in a module: an in-body task caller of its extern task prototype above and of an extern function prototype above)
module top;
  class F;
    extern task tk(input int a, input int b = 3, output int c);
    extern function int mt(int a, int b = 1, int c = 2);
    task run(int x);
      int y;
      tk(.c(y), .b(4), .a(x));
      y = mt(.c(x), .b(0), .a(1));
    endtask
  endclass
  task F::tk(input int a, input int b = 3, output int c);
    c = a + b;
  endtask
  function int F::mt(int a, int b = 1, int c = 2); return a + b + c; endfunction
endmodule
