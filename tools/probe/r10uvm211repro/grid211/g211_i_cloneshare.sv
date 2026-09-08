// r10uvm211 arm I — CLONE-TO-CLONE SHARING.  TWO clone declarations share ONE
// array object between THEMSELVES and no home declaration reaches it, so the
// owner mask is 1 and § 207's RE-POINT still owns that face: this arm must not
// change between the binaries beyond what § 207 already did, and must never
// score AWAY-GOLDEN.  It is the positive control that the split fires only on
// the mask § 207 refused.
package p211a_i;
  typedef bit [63:0] bt211i;
  typedef struct { bt211i i_addr211; bt211i i_data211; } si211;

  function automatic int fi211a();
    si211 la211[$];
    return la211.size();
  endfunction
  function automatic int fi211b();
    si211 lb211[$];
    return lb211.size();
  endfunction
endpackage

package p211b_i;
  import p211a_i::*;
  function automatic int gb211i();
    return fi211a() + fi211b();
  endfunction
endpackage

module g211_i_cloneshare;
  import p211b_i::*;
  int r211i;
  initial r211i = gb211i();
endmodule
