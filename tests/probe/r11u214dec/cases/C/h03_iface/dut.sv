// § classTdAliasLastWriter214 — the class-specialization typedef imported by an interface
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) pool_t;
  class user;
    pool_t q;
  endclass
endpackage
interface ifc;
  import p::*;
endinterface
