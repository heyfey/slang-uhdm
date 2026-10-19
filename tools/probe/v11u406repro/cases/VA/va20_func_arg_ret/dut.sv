// § unitAssocTdMultiDim406
typedef logic [1:0] t2 [2][3];
module top;
  function automatic t2 f(input t2 a);
    return a;
  endfunction
  t2 x, y;
  initial y = f(x);
endmodule
