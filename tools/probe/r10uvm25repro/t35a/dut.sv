// t35a — § typedefAliasSharesTypespec25, both arms, in ONE class each, plus the
// negative control.
//
//   K  : the REQ/RSP arm — two type params, the second DEFAULTING to the first,
//        one typedef each.  Golden: ONE class_typespec, named after the
//        SOURCE-LAST typedef, at the alphabetically FIRST key.
//   L  : the type-param-default arm — three type params rooted at one `int`
//        default, one typedef each.  Golden: ONE int_typespec.
//   M  : the NEGATIVE control — two INDEPENDENT type params with the same
//        default.  Different roots, so nothing may collapse.
//   N  : the second negative control — two ordinary typedefs of the same class,
//        no type parameter in sight.  Nothing may collapse.
package pk1;

  class Base;
    int x;
  endclass

  class Other;
    int y;
  endclass

  class K #(type REQ = Base, type RSP = REQ);
    typedef K #(REQ, RSP) this_type;
    typedef REQ req_type;
    typedef RSP rsp_type;
    int k;
  endclass

  class L #(type IMP = int, type REQ_IMP = IMP, type RSP_IMP = IMP);
    typedef IMP     this_imp_type;
    typedef REQ_IMP this_req_type;
    typedef RSP_IMP this_rsp_type;
    int l;
  endclass

  class M #(type A = Base, type B = Base);
    typedef A aa_type;
    typedef B bb_type;
    int m;
  endclass

  class N;
    typedef Base n1_type;
    typedef Base n2_type;
    int n;
  endclass

endpackage

module top;
  import pk1::*;
  K #(Base, Base) k_h;
  L #(int, int, int) l_h;
  M #(Base, Base) m_h;
  N n_h;
  initial begin
    k_h = new();
    l_h = new();
    m_h = new();
    n_h = new();
  end
endmodule
