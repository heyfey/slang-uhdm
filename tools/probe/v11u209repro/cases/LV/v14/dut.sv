// § tfItemInitLocalAtType209: named typedef locals with and without an initializer side by side
module top;
  typedef logic [7:0] b_t;
  function int f;
    b_t x;
    b_t y = 8'd4;
    x = y;
    return x;
  endfunction
  int r;
  initial r = f();
endmodule
