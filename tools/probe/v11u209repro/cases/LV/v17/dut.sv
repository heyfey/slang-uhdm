// § tfItemInitLocalAtType209: an implicit-type var local with an initializer in a paren-less function
module top;
  function int h;
    var v = 1'b1;
    var [3:0] w = 4'd2;
    return v + w;
  endfunction
  int r;
  initial r = h();
endmodule
