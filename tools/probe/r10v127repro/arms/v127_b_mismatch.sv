// r10v127 VERIFIER grid B — ACTUAL-vs-FORMAL TYPE MISMATCH inside the
// out-of-body window.  The stamp copies the FORMAL's typespec onto the ACTUAL,
// so a mismatch is where a wrong stamp is most visible.  Callees are DPI-C
// imports.  MEASUREMENT ONLY.
package Fernbrake;
  typedef enum int { GLIM_A = 1, GLIM_B = 6 } glim_e;
  typedef string  label_t;
  typedef logic [7:0] octet_t;

  import "DPI-C" function int mmInt   (int      a1);
  import "DPI-C" function int mmByte  (byte     a1);
  import "DPI-C" function int mmOctet (octet_t  a1);
  import "DPI-C" function int mmStr   (string   a1);
  import "DPI-C" function int mmLabel (label_t  a1);
  import "DPI-C" function int mmReal  (real     a1);
  import "DPI-C" function int mmGlim  (glim_e   a1);
  import "DPI-C" function int mmShort (shortint a1);

  class Windrow;
    int      wInt   = 4;
    byte     wByte  = 8'h05;
    octet_t  wOct   = 8'h0f;
    string   wStr   = "sw";
    label_t  wLab   = "lb";
    real     wReal  = 1.5;
    glim_e   wGlim  = GLIM_B;
    shortint wShort = 16'h11;
    // MATCHED
    extern function int okInt   ();
    extern function int okStr   ();
    extern function int okGlim  ();
    // MISMATCHED, both directions
    extern function int byteToInt ();
    extern function int intToByte ();
    extern function int intToOctet();
    extern function int shortToInt();
    extern function int strToLabel();
    extern function int labelToStr();
    extern function int intToReal ();
    extern function int glimToInt ();
    extern function int castToGlim ();
  endclass

  function int Windrow::okInt   (); return mmInt(wInt);     endfunction
  function int Windrow::okStr   (); return mmStr(wStr);     endfunction
  function int Windrow::okGlim  (); return mmGlim(wGlim);   endfunction
  function int Windrow::byteToInt (); return mmInt(wByte);  endfunction
  function int Windrow::intToByte (); return mmByte(wInt);  endfunction
  function int Windrow::intToOctet(); return mmOctet(wInt); endfunction
  function int Windrow::shortToInt(); return mmInt(wShort); endfunction
  function int Windrow::strToLabel(); return mmLabel(wStr); endfunction
  function int Windrow::labelToStr(); return mmStr(wLab);   endfunction
  function int Windrow::intToReal (); return mmReal(wInt);  endfunction
  function int Windrow::glimToInt (); return mmInt(wGlim);  endfunction
  function int Windrow::castToGlim (); return mmGlim(glim_e'(wInt)); endfunction

  // the SAME mismatches from a FREE package function (the shape r10buvm8
  // already stamped) — a control that must not move
  function automatic int freeByteToInt(byte fb); return mmInt(fb);   endfunction
  function automatic int freeIntToByte(int  fi); return mmByte(fi);  endfunction
endpackage

module Fernbrake_top;
  import Fernbrake::*;
  Windrow wr;
  int got;
  initial begin
    wr = new();
    got = wr.byteToInt();
  end
endmodule
