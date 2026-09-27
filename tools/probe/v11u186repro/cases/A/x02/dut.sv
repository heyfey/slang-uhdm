// § assocPromotedBoundAtBracket183 (a package function, a class-typed key, a string typedef key)
package p;
  class k; endclass
  typedef string s_t;
  function automatic int f();
    int m[k];
    int n[s_t];
    return m.size() + n.size();
  endfunction
endpackage
module top; endmodule
