// § parenCallWrittenArgs477
class comp;
  bit b;
  function bit f(int a, int c = 5);
    return 1;
  endfunction
  function void write(int rec);
    b = (f(rec));
  endfunction
endclass
module top;
endmodule
