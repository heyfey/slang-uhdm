// § clsPropLawSAliasName243
// one typedef binding a property of two classes, a function local and a module variable
package p;
  typedef int i_t;
  class a; i_t v; endclass
  class b; i_t v; static i_t w; endclass
  function i_t f(); i_t t; t = 1; return t; endfunction
endpackage
module top;
  import p::*;
  i_t m;
  a oa;
  b ob;
endmodule
