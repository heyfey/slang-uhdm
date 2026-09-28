// § tfItemInitLocalAtType209: a queue local with an initializer in a paren-less function
module top;
  function int h;
    int q[$] = {1, 2};
    return q.size();
  endfunction
  int r;
  initial r = h();
endmodule
