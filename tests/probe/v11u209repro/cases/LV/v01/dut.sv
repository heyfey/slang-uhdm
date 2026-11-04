// § tfItemInitLocalAtType209: a named struct typedef local with an initializer in a paren-less module function
module top;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function int f;
    s_t x = '0;
    return x.a;
  endfunction
  int r;
  initial r = f();
endmodule
