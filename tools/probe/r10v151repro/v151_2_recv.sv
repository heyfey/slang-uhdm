// r10v151 (VERIFIER) arm 2 — RECEIVER SHAPES the implementer's arm B does not
// reach: struct members, dotted and computed subscripts, dynamic / fixed /
// associative receivers, `super.`, and the KEYWORD methods on each.
// (A CALL-RESULT receiver -- `mk().q.sort() with (item);` -- is REFUSED by
// Surelog's own parser with PA0207 and is recorded in VERIFIER.md instead of
// scored here; a PACKED-array reduction lives in arm 2p because slang refuses
// it.)  MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package Rpk2;
  typedef struct {
    int  vq[$];
    bit  vb[$];
  } Blob2;
  class Leaf2;
    int  lq[$];
    bit  lb[$];
    int  n;
  endclass
  class Base2;
    int  bq[$];
    task tb2; bq.sort() with ( item ); endtask
  endclass
  class Deriv2 extends Base2;
    Blob2  blob;
    Leaf2  leaf;
    int    dyn2[];
    int    amap[string];
    task tb3;
      int   k;
      int   e;
      int   grid[4][$];
      int   fixd[6];
      Leaf2 larr[3];
      k = 1;
      // ---- STRUCT MEMBER receivers ----
      blob.vq.sort() with ( item );        // struct field, dotted
      blob.vb.xor();                       // struct field, KEYWORD method
      // ---- DOTTED / COMPUTED SUBSCRIPTS on a single-component receiver ----
      grid[k].sort() with ( item );        // variable index
      grid[k + 1].sort() with ( item );    // expression index
      grid[leaf.n].sort() with ( item );   // DOTTED index
      grid[2].and();                       // KEYWORD method, indexed
      larr[0].lq.sort() with ( item );     // indexed obj . field
      // ---- NON-QUEUE receivers ----
      dyn2.sort() with ( item );
      dyn2.or();
      fixd.sort() with ( item );
      fixd.and();
      amap.find_index() with ( item > 0 );
      amap.sum() with ( item );
      // ---- super. / this. rooted ----
      super.bq.sort() with ( item );
      this.dyn2.sort() with ( item );
      this.amap.find_first() with ( item > 1 );
      // ---- EXPRESSION position twins of the KEYWORD forms (the fence) ----
      e = dyn2.or();
      if (fixd.and()) k = 2;
      $display("%0d", grid[2].and());
      e = k;
    endtask
  endclass
endpackage
