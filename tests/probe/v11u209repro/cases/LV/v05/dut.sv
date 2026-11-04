// § tfItemInitLocalAtType209: an automatic local in a paren-less static package function
package q;
  function int h;
    automatic int d = 5;
    return d;
  endfunction
endpackage
module top;
  int r;
  initial r = q::h();
endmodule
