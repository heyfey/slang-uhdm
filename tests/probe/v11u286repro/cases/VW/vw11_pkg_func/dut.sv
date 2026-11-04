// § withCallParenSyntax286
package pk;
  function automatic int g(int q[$]);
    return (q.sum(e) with (e * e)) + 0;
  endfunction
endpackage
module top;
  int r;
  int q[$] = '{1, 2};
  initial r = pk::g(q);
endmodule
