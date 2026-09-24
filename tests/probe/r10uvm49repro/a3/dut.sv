// a3 — THREE-DEEP CHAIN TOPOLOGY.  Three typedefs of the SAME specialisation.
// NAME order: aaa < mmm < zzz.  SOURCE order: zzz, mmm, aaa (exactly reversed),
// so source order and name order disagree at EVERY position.
// Question: do the two non-base names BOTH alias the name-first base `aaa_3_t`
// directly, or does `zzz_3_t` chain through `mmm_3_t`?
// The UVM corpus has three typedefs but its head only exposes ONE alias, so the
// chain topology is unmeasured there.
package p49c;

  class gc49 #(type KEY = int, type T = int);
    int k;
  endclass

  typedef gc49#(string, int) zzz_3_t;
  typedef gc49#(string, int) mmm_3_t;
  typedef gc49#(string, int) aaa_3_t;

  class holder49;
    zzz_3_t hz;
    mmm_3_t hm;
    aaa_3_t ha;
  endclass

endpackage

module a3_top;
  import p49c::*;
  zzz_3_t mz;
endmodule
