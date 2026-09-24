// r10svs4repro/g1_thisidx.sv — THE GRID for § the indexed this-member select.
//
// One cell per (RECEIVER) x (INDEX KIND) x (SYNTACTIC POSITION), all inside a
// class METHOD so nothing but the receiver/index/position varies.  Golden
// (Surelog) is the oracle; every cell is read for THREE fields:
//   * the hier_path's vpiName            (index PRESENT or ABSENT)
//   * the LAST path element's vpiType    (bit_select vs plain ref_obj)
//   * both elements' spans               (member token vs own token)
//
// `data` is a DYNAMIC array of `byte`, byte-for-byte the SVSwitch declaration
// (`rand byte data[]`), because the head under test is on THAT declaration; `fx`
// is the fixed-size twin and `q` the queue twin, so array KIND is a grid axis
// rather than an assumption.  One statement per line, cell tag in the comment,
// so a line number in the dump names the cell.
class Grid;
   byte data[];
   byte fx[4];
   int  q[$];
   int  m2[2][3];
   int  scalar;

   function void f(Grid pkt, int k);
      int i;
      int r;
      foreach (this.data[i])                 // -- foreach header, this-target
        if (pkt.data[i] !== this.data[i])    // c2 pkt / c1 this   THE FREE CELL
          r = 1;
      for (int j = 0; j < 4; j++)
        if (this.data[j] !== pkt.data[j])    // c3 this / c4 pkt   for-loop var
          r = 2;
      if (this.data[2] !== pkt.data[2])      // c5 this / c6 pkt   CONSTANT idx
        r = 3;
      if (this.data[k] !== pkt.data[k])      // c7 this / c8 pkt   arg-var idx
        r = 4;
      this.data[k] = 8'h11;                  // c9  LVALUE this, var idx
      pkt.data[k]  = 8'h12;                  // c10 LVALUE pkt, var idx
      this.data[1] = 8'h13;                  // c11 LVALUE this, const idx
      g(this.data[k]);                       // c12 CALL ARG this
      g(pkt.data[k]);                        // c13 CALL ARG pkt
      r = this.data[k];                      // c14 plain assign rhs, this
      r = pkt.data[k];                       // c15 plain assign rhs, pkt
      r = this.fx[k];                        // c16 FIXED array, this
      r = pkt.fx[k];                         // c17 FIXED array, pkt
      r = this.q[k];                         // c18 QUEUE, this
      r = pkt.q[k];                          // c19 QUEUE, pkt
      r = this.m2[k][1];                     // c20 2-D unpacked, this
      r = pkt.m2[k][1];                      // c21 2-D unpacked, pkt
      r = this.scalar;                       // c22 UNINDEXED this (control)
      r = data[k];                           // c23 NO receiver written
      r = this.data[k+1];                    // c24 this, expression index
      r = pkt.data[this.data[k]];            // c25 this-path AS an index
   endfunction

   function void g(byte v);
   endfunction
endclass

// A MODULE-SCOPE twin: no `this` is writable here, so this is the control that
// says the bare / `obj.` forms are untouched by whatever the this-law does.
module m;
   Grid gh;
   int rr;
   int kk;
   initial begin
      rr = gh.data[kk];                      // c26 module-scope obj.member[var]
      rr = gh.data[1];                       // c27 module-scope obj.member[const]
   end
endmodule
