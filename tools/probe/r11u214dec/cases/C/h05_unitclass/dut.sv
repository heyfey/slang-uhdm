// § classTdAliasLastWriter214 — the class-specialization typedef through a $unit import, a $unit class and a module
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) pool_t;
  class user;
    pool_t q;
  endclass
endpackage
import p::*;
class env;
  int x;
endclass
module top;
  env e;
endmodule
