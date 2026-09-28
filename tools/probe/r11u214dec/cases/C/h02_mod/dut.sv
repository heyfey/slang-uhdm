// § classTdAliasLastWriter214 — the class-specialization typedef imported by a module
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) pool_t;
  class user;
    pool_t q;
  endclass
endpackage
module top;
  import p::*;
endmodule
