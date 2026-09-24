// v212 ADVERSARIAL v1 — BASE-CHOICE ORDER.  c9 with the package renamed so that
// OUR group key ("work@ub" < "zp::zcb") picks the COMPILATION-UNIT member as the
// base, while c9's key ("rp::rcb" < "work@ub") picked the package one.  If
// Surelog's base is still the package class, the clone half now copies the
// WRONG way round and the listing survives where golden has none.
package zp;
  class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass
  class zcb extends baseb;
    typedef regb #(zcb, "zcb") tidb;
  endclass
endpackage
import zp::*;
class ub extends baseb;
  typedef regb #(ub, "ub") tidb;
endclass
module topb; import zp::*; ub vb; zcb zv; initial begin vb = null; zv = null; end endmodule
