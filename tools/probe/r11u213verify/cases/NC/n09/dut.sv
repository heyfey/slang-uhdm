// § namedUnlinkedWrittenOrder207 (declines: an empty named argument, a positional after named is illegal so a positional prefix then named; an unwritten output formal)
package p;
  class F;
    extern function int mt(int a, int b = 1, int c = 2);
    extern task tk(input int a, output int o, input int d = 7);
    extern task g(int v);
  endclass
  task F::g(int v);
    int r, o;
    r = mt(.c(v), .b(), .a(1));
    r = mt(v, 5, .c(1));
    tk(.d(1), .a(v), .o(o));
  endtask
  function int F::mt(int a, int b = 1, int c = 2); return a + b + c; endfunction
  task F::tk(input int a, output int o, input int d = 7); o = a + d; endtask
endpackage
module top; endmodule
