// § tfItemInitLocalAtType209: an enum typedef local with an initializer in a paren-less module function
module top;
  typedef enum logic [1:0] { A, B, C } e_t;
  function int f;
    e_t x = B;
    return int'(x);
  endfunction
  int r;
  initial r = f();
endmodule
