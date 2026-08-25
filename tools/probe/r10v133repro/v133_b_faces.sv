// r10v133 arm B - the ARGUMENT FACES the law must not disturb, plus the call
// faces it owns, side by side in ONE class.  MEASUREMENT ONLY.
package pv133b;
  typedef enum bit [2:0] { EA=0, EB=1, EC=4 } ev133_t;
  typedef struct packed { bit [7:0] hi; bit [3:0] lo; } sv133_t;
  typedef bit [5:0] tv133_t;
  parameter int GPV133 = 9;

  class inner133b;
    int    iq[$];
    int    iv;
    function int gi133b(); return 1; endfunction
  endclass

  class faces133b;
    ev133_t     e1;
    sv133_t     s1;
    tv133_t     t1;
    string      st1;
    int         qa[$];
    int         qb[string];
    int         qc[];
    bit [15:0]  bv;
    bit [7:0]   ba [4];
    inner133b   ih;
    localparam int LPV133 = 5;

    function int mf133b(); return 2; endfunction
    function sv133_t sf133b(); return s1; endfunction
    function string tf133b(); return st1; endfunction

    function void probe133();
      int r;
      // --- faces that must NOT move (no call anywhere) ---
      r = $bits(int);            // F01 type keyword
      r = $bits(tv133_t);        // F02 typedef
      r = $bits(sv133_t);        // F03 struct typedef
      r = $bits(ev133_t);        // F04 enum typedef
      r = $bits(7);              // F05 literal
      r = $bits(GPV133);         // F06 package parameter
      r = $bits(LPV133);         // F07 class localparam
      r = $bits(bv);             // F08 plain property
      r = $bits(bv[2]);          // F09 bit-select
      r = $bits(bv[7:4]);        // F10 part-select
      r = $bits(s1.hi);          // F11 member access
      r = $bits(ba[1]);          // F12 array element
      r = $bits(e1);             // F13 enum variable
      r = $bits(st1);            // F14 string variable
      r = $bits(ih);             // F15 CLASS HANDLE
      r = $bits(qa);             // F16 whole queue
      r = $bits(qb);             // F17 whole assoc array
      r = $bits(qc);             // F18 whole dynamic array
      r = $bits(ih.iv);          // F19 member through a class handle
      // --- the call faces the law owns ---
      r = $bits(mf133b());       // F20 own method call
      r = $bits(sf133b());       // F21 call returning a struct
      r = $bits(tf133b());       // F22 call returning a string
      r = $bits(qa.size());      // F23 queue size
      r = $bits(qb.size());      // F24 assoc size
      r = $bits(qb.num());       // F25 assoc num
      r = $bits(qc.size());      // F26 dyn size
      r = $bits(st1.len());      // F27 string len
      r = $bits(e1.name());      // F28 enum name()
      r = $bits(e1.num());       // F29 enum num()
      r = $bits(ih.gi133b());    // F30 call through a class handle
      r = $bits(ih.iq.size());   // F31 hier receiver .size()
      r = $bits(qa.sum());       // F32 reduction method
      r = $bits(ba.sum());       // F33 fixed array reduction method
      if (r == 0) r = 1;
    endfunction
  endclass
endpackage
