// r10v166 ARM E — the vpiAutomatic FIELD (a cmp-READ field on `variables`,
// UHDM generated variables.cpp:256) on the object the law mints, at BOTH
// sites, plus the paren-less-function decline (R1).
package ae166_pkg;

  class Cell166;
    int t;
  endclass

  class Auto166;
    typedef Cell166 aq166_t [$];

    // SITE 1 — the BLOCK-ITEM local (a nested `begin`), where the patch DOES
    // write the flag.  Both the written-`automatic` and the plain form.
    function int blk166();
      int n166;
      begin : b1_166
        automatic aq166_t bAuto166;             // written `automatic`
        aq166_t          bPlain166;             // no keyword
        n166 = bAuto166.size() + bPlain166.size();
      end
      return n166;
    endfunction

    // the same, in a STATIC method and in a TASK
    static function int sblk166();
      int n166;
      begin : b2_166
        automatic aq166_t sAuto166;
        aq166_t          sPlain166;
        n166 = sAuto166.size() + sPlain166.size();
      end
      return n166;
    endfunction

    task tblk166(output int n166);
      begin : b3_166
        automatic aq166_t tAuto166;
        aq166_t          tPlain166;
        n166 = tAuto166.size() + tPlain166.size();
      end
    endtask

    // SITE 2 — the SUBROUTINE-BODY (TF-ITEM) local, where the patch does NOT
    // write the flag (the three array factories beside it do not either).
    function int tf166();
      automatic aq166_t fAuto166;
      aq166_t          fPlain166;
      return fAuto166.size() + fPlain166.size();
    endfunction

    // an AUTOMATIC method: every local is automatic without a keyword
    function automatic int amth166();
      aq166_t mq166;
      int n166;
      begin : b4_166
        aq166_t nq166;
        n166 = nq166.size();
      end
      return mq166.size() + n166;
    endfunction

    // a STATIC method with an explicit `static` local
    static function int smth166();
      static aq166_t stq166;
      return stq166.size();
    endfunction
  endclass

  // R1 — the PAREN-LESS function header (SITE 2's `blockItems9` declines).
  class Paren166;
    typedef Cell166 pq166_t [$];
    function int noParen166;
      pq166_t pv166;
      noParen166 = pv166.size();
    endfunction
    function int withParen166();
      pq166_t wv166;
      return wv166.size();
    endfunction
  endclass

endpackage

module ae166_top;
  import ae166_pkg::*;
  Auto166  a166;
  Paren166 p166;
  int r166, t166;
  initial begin
    a166 = new(); p166 = new();
    a166.tblk166(t166);
    r166 = a166.blk166() + Auto166::sblk166() + t166 + a166.tf166()
         + a166.amth166() + Auto166::smth166()
         + p166.noParen166() + p166.withParen166();
  end
endmodule
