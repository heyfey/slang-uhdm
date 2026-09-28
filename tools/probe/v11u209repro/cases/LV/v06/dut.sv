// § tfItemInitLocalAtType209: a var-keyword local in a paren-less function
module top;
  function int h;
    var int g = 6;
    return g;
  endfunction
  int r;
  initial r = h();
endmodule
