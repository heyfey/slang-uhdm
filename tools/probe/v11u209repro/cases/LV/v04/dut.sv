// § tfItemInitLocalAtType209: a const local in a paren-less package function
package q;
  function int h;
    const int c = 4;
    return c;
  endfunction
endpackage
module top;
  int r;
  initial r = q::h();
endmodule
