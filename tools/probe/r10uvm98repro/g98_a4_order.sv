// r10uvm98 arm a4 — the ORDER inside each group, and the QUALIFIED spelling.
// Two packages declaring the same class-typedef name, and inside one package
// three classes declaring it; the reference lives in the LAST of them.
package bpk98;
  class m2cls98 #(type T = int);
    typedef m2cls98 #(T) rank_t;          // bpk98::m2cls98  -- 2nd package
  endclass
endpackage

package apk98;
  class w9cls98 #(type T = int);          // 'apk98::w9cls98' sorts before
    typedef w9cls98 #(T) rank_t;          // 'bpk98::m2cls98' -> should WIN
  endclass
endpackage

package cpk98;
  class q1base98 #(type T = int);
    typedef q1base98 #(T) rank_t;
    typedef q1base98 #(T) uniq98_t;       // sole declarer of uniq98_t
  endclass
  class r2mid98 extends q1base98 #(int);
    typedef r2mid98 rank_t;               // a MIDDLE re-declaration
  endclass
  class s3use98 extends q1base98 #(int);
    function void bare(rank_t p); endfunction         // BARE inherited name
    function void qual(q1base98 #(int)::rank_t p); endfunction  // QUALIFIED
    function void solo(uniq98_t p); endfunction       // sole-declarer name
    extern function void oob(uniq98_t p);
  endclass
  function void s3use98::oob(uniq98_t p); endfunction // OOB definition
endpackage

module mtop98d;
  import apk98::*; import bpk98::*; import cpk98::*;
  w9cls98 #(int) h1; m2cls98 #(int) h2; q1base98 #(int) h3;
  r2mid98 h4; s3use98 h5;
  initial begin h1 = new(); h2 = new(); h3 = new(); h4 = new(); h5 = new(); end
endmodule
