// § tfItemInitLocalAtType209: a package-qualified typedef local and a same-position declarator in a second function
package q;
  typedef logic [3:0] n_t;
endpackage
module top;
  function int f1;
    q::n_t e = 4'd3;
    return e;
  endfunction
  function int f2;
    q::n_t e = 4'd4;
    return e;
  endfunction
  int r;
  initial r = f1() + f2();
endmodule
