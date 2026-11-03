// § parenCallWrittenArgs477
package p;
  function automatic bit f(int a, int c = 5);
    return 1;
  endfunction
endpackage
module top;
  bit b;
  int rec;
  initial b = (p::f(rec));
endmodule
