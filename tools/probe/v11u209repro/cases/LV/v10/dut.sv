// § tfItemInitLocalAtType209: a package typedef local with an initializer in a paren-less package function
package q;
  typedef logic [3:0] n_t;
  function int h;
    n_t e = 4'd3;
    return e;
  endfunction
endpackage
module top;
  int r;
  initial r = q::h();
endmodule
