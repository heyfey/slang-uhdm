// a1 — THE DECIDER, cleaned.  Is the class-handle-typedef ALIAS BASE the
// SOURCE-FIRST typedef or the NAME-FIRST one?
// zzz_first_t is written FIRST (line 15) and sorts LAST.
// aaa_second_t is written SECOND (line 16) and sorts FIRST.
// Derived from pass-49 slot-1 t49a, with the plain `holder49 h;` net REMOVED:
// that net trips an EARLIER head (missing ref_typespec on a class-typed
// logic_net) which masks the target pair.
package p49a;

  class gc49 #(type KEY = int, type T = int);
    int k;
    int t;
  endclass

  typedef gc49#(string, int) zzz_first_t;
  typedef gc49#(string, int) aaa_second_t;

  class holder49;
    zzz_first_t hz;
    aaa_second_t ha;
  endclass

endpackage

module a1_top;
  import p49a::*;
  zzz_first_t mz;
  aaa_second_t ma;
endmodule
