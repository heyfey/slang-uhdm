// § assocPromotedBoundAtBracket183 / § assocBracketPkgOnly186 (a class inside a module, typedef key)
module top;
  typedef enum { K0, K1 } k_t;
  class c;
    function void f();
      bit m[k_t];
      m[K0] = 1;
    endfunction
  endclass
endmodule
