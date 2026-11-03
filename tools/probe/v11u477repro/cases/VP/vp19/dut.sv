// § parenCallWrittenArgs477
class inner;
  function int m(int a, int b = 7); return a + b; endfunction
endclass
class outer;
  inner h;
  function new(); h = new; endfunction
endclass
module top(output int z);
  outer o;
  initial begin o = new; z = (o.h.m(1)); end
endmodule
