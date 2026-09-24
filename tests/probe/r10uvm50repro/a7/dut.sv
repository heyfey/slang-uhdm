// a7 — THE TRANSITIVE RE-EXPORT, the cell no pass-49 arm covered (r10uvm49
// README §5 / trap (4) of the pass-50 brief).
// Corpus shape (SeqDriver): `module top_tb` over `package adpcm_pkg` which does
// `import uvm_pkg::*;`, and golden's vpiInstance on the published typedef is the
// INTERMEDIATE package, not the defining one.
// The declaration under test is a CLASS PROPERTY of a class in the DEFINING
// package — exactly uvm_report_handler::id_verbosities at
// uvm-1.2/src/base/uvm_report_handler.svh:62.
// aaa_v_t sorts FIRST (so it is the alias base, per the pass-49 a1/a3 name-order
// law); zzz_a_t sorts last and must carry aaa_v_t's span plus a vpiTypedefAlias.
package p50u;

  class gc50 #(type KEY = int, type T = int);
    int k;
    int t;
  endclass

  typedef gc50#(string, int) aaa_v_t;
  typedef gc50#(string, int) zzz_a_t;

  class rh50;
    aaa_v_t id_v;
    zzz_a_t id_a;
  endclass

endpackage

package p50m;
  import p50u::*;
  class drv50 extends rh50;
    int extra;
  endclass
endpackage

module a7_top;
  import p50m::*;
  drv50 d;
endmodule
