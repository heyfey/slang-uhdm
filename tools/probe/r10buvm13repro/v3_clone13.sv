// r10buvm13 arm v3 — THE WILDCARD-IMPORT CLONE fence, the ONE fence the corpus
// census added to § formalDefaultBindsLikeBody13.
//
// Golden disagrees with ITSELF about two copies of one text: the HOME package's
// `uvm_report` binds `severity` and the copy a wildcard import materialises in
// the importing package does not (MiniAmiq: `uvm_pkg::uvm_report` act1 vs
// `svaunit_pkg::uvm_report` act0, both views, both `severity` refs; SeqDriver
// says the same with `adpcm_pkg::uvm_report`).  This arm writes the shape by
// hand so the fence is a WITNESS and not only a corpus reading.
package p13home;
  typedef enum int {H13_A = 1, H13_B = 2} h13_t;
  int hvar13 = 3;
  function automatic int hf_earlier(int a, int b = a);   return a + b; endfunction
  function automatic int hf_enumi(int v = H13_B);        return v; endfunction
  function automatic int hf_var(int v = hvar13);         return v; endfunction
  task automatic ht_earlier(input int a, input int b = a); endtask
endpackage

// The IMPORTER: a wildcard import makes p13home's subroutines members of
// p13imp, and both producers materialise a CLONE of each one under p13imp.
package p13imp;
  import p13home::*;
  function automatic int if13_use(int a);  return hf_earlier(a); endfunction
endpackage

module m13clone;
  import p13imp::*;
  int z;
  initial begin
    z = if13_use(1);
    z = p13home::hf_earlier(1);
    z = p13home::hf_enumi();
    z = p13home::hf_var();
    p13home::ht_earlier(1);
  end
endmodule
