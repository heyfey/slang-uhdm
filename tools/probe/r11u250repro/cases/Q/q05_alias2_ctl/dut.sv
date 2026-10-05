// § pkgAliasOfKwTd250 (control: an alias of an alias and a cross-package alias stay outside the law)
package a;
  typedef int i_t;
endpackage
package p;
  import a::*;
  typedef i_t x_t;
  typedef shortint s_t;
  typedef s_t t_t;
  typedef t_t v_t;
endpackage
module top;
  import p::*;
  x_t q;
  v_t r;
endmodule
