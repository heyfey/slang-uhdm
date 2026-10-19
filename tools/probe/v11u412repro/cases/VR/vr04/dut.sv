// § tdAtomRetAliasTwin412
package pk;
  typedef int i_t;
  class C;
    typedef string s_t;
    function s_t name(); return "c"; endfunction
    function i_t num(); return 1; endfunction
  endclass
endpackage
module top;
  pk::C c;
endmodule
