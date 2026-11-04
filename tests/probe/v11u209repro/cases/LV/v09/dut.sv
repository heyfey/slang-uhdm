// § tfItemInitLocalAtType209: a signed vector local with an initializer in a paren-less function
module top;
  function int h;
    logic signed [3:0] s = -4'sd1;
    int unsigned u = 3;
    return s + u;
  endfunction
  int r;
  initial r = h();
endmodule
