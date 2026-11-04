// § clsPropLawSAliasName243
// a class declared in a module and a $unit class, properties of package typedefs
package p;
  typedef int i_t;
  typedef bit [3:0] n_t;
endpackage
import p::*;
class uc;
  i_t m_u;
  n_t m_n;
endclass
module top;
  class mc;
    i_t m_m;
  endclass
  mc o;
  uc u;
endmodule
