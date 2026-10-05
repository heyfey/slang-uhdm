// § lawSStringTd243
// an interface variable and a class in a module of a string typedef
package p;
  typedef string str_t;
endpackage
interface ifc;
  import p::*;
  str_t name;
endinterface
module top;
  import p::*;
  ifc i();
  class lc;
    str_t m;
  endclass
  lc o;
endmodule
