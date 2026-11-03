// § parenCallWrittenArgs477
module top;
  function bit f(int a, int c = 5);
    return 1;
  endfunction
  bit b;
  int rec;
  initial b = (f(rec));
endmodule
