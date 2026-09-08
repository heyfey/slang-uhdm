// r10uvm211 arm C — THE SHARING CONTROL, this face's decisive question.  A
// HOME body declares the SAME array-of-struct shape, WITH ITS OWN `foreach`,
// as the body the importer clones, so the two producers can be compared on
// whether golden SPLITS the clone's array per declaration while keeping the
// HOME's member alias QUALIFIED.  AWAY-GOLDEN on any home cell here convicts
// the law.
package p211a_c;
  typedef bit [63:0] bt211c;
  typedef struct { bt211c c_addr211; bt211c c_data211; } sc211;

  function automatic int fhome211();
    sc211 lhome211[$];                    // HOME body local: MUST STAY QUAL
    int t211c;
    foreach (lhome211[i211c])
      t211c = t211c + int'(lhome211[i211c].c_addr211);
    return t211c;
  endfunction

  function automatic int fboth211();
    sc211 lboth211[$];                    // reached from the clone as well
    int u211c;
    foreach (lboth211[j211c])
      u211c = u211c + int'(lboth211[j211c].c_data211);
    return u211c;
  endfunction
endpackage

package p211b_c;
  import p211a_c::*;
  function automatic int gb211c();
    return fboth211() + fhome211();
  endfunction
endpackage

module g211_c_share;
  import p211b_c::*;
  int r211c;
  initial r211c = gb211c();
endmodule
