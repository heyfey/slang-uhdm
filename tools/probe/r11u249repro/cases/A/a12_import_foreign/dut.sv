// § clsPropWholeArrTd249
package a;
  typedef byte b_t[2];
endpackage
package p;
  import a::*;
  class c;
    b_t m_b;
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
