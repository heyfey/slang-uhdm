// § tfItemInitLocalAtType209: two declarators with initializers in a paren-less function
module top;
  function int h;
    int a = 1, b = 2;
    return a + b;
  endfunction
  int r;
  initial r = h();
endmodule
