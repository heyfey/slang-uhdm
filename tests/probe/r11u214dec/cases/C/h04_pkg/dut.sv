// § classTdAliasLastWriter214 — the class-specialization typedef imported by a second package
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) pool_t;
  class user;
    pool_t q;
  endclass
endpackage
package q;
  import p::*;
endpackage
