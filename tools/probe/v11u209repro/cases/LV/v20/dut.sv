// § tfItemInitLocalAtType209: a paren-less function in a program with initialized locals
program prg;
  function int f;
    int a = 2;
    bit [2:0] b = 3'd5;
    return a + b;
  endfunction
  int r;
  initial r = f();
endprogram
module top;
endmodule
