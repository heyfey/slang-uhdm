// (r11u191 N0215) a module function and task formal default reading a formal and an enum constant
module top;
  typedef enum { A0, A1 } e_t;
  function int f(int a, int b = a + 1, e_t c = A1);
    return a + b;
  endfunction
  task t(input int a, input int b = (a > 2) ? a : 2);
  endtask
endmodule
