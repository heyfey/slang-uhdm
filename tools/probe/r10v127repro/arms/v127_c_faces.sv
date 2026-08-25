// r10v127 VERIFIER grid C — the ACTUAL's FACE inside the out-of-body window:
// the enclosing method's own formal, a local, a class property, `this.`,
// `super.`, a PACKAGE variable, a bit-select, a member chain, a literal, a
// concatenation, and a CALL RESULT.  Callees are DPI-C imports.
// MEASUREMENT ONLY.
package Halyard;
  import "DPI-C" function int hlInt (int a1);
  import "DPI-C" function int hlStr (string a1);
  import "DPI-C" function int hlByte(byte a1);
  import "DPI-C" function int hlTwo (int a1, string a2);

  int pkgCount = 12;
  string pkgTag = "pt";

  class Baseplate;
    int      bProp  = 2;
    string   bTag   = "bt";
    logic [7:0] bVec = 8'h3c;
  endclass

  class Kingpost extends Baseplate;
    int      kProp = 5;
    Baseplate kObj;
    int      kArr [4];
    extern function int fFormal (int seed);        // the method's own formal
    extern function int fLocal  ();                // a local variable
    extern function int fProp   ();                // a class property
    extern function int fThis   ();                // this.prop
    extern function int fSuper  ();                // super.prop
    extern function int fPkgVar ();                // a PACKAGE variable
    extern function int fBitSel ();                // a single-bit select
    extern function int fPartSel();                // a part-select
    extern function int fMember ();                // a member chain
    extern function int fArrIdx ();                // an array index
    extern function int fLiteral();                // literals
    extern function int fConcat ();                // a concatenation
    extern function int fCallRes();                // a call RESULT
    extern function int fMixed  (int seed);        // two faces at once
  endclass

  function int Kingpost::fFormal (int seed); return hlInt(seed);        endfunction
  function int Kingpost::fLocal  ();
    int loc = 7;
    return hlInt(loc);
  endfunction
  function int Kingpost::fProp   (); return hlInt(kProp);              endfunction
  function int Kingpost::fThis   (); return hlInt(this.kProp);         endfunction
  function int Kingpost::fSuper  (); return hlInt(super.bProp);        endfunction
  function int Kingpost::fPkgVar (); return hlInt(pkgCount);           endfunction
  function int Kingpost::fBitSel (); return hlByte(bVec[3]);           endfunction
  function int Kingpost::fPartSel(); return hlByte(bVec[7:4]);         endfunction
  function int Kingpost::fMember (); return hlInt(kObj.bProp);         endfunction
  function int Kingpost::fArrIdx (); return hlInt(kArr[2]);            endfunction
  function int Kingpost::fLiteral(); return hlTwo(37, "nineteen");     endfunction
  function int Kingpost::fConcat (); return hlByte({bVec[3:2], bVec[1:0]}); endfunction
  function int Kingpost::fCallRes(); return hlInt(hlByte(bVec[3:0]));  endfunction
  function int Kingpost::fMixed  (int seed); return hlTwo(seed + kProp, pkgTag); endfunction
endpackage

module Halyard_top;
  import Halyard::*;
  Kingpost kp;
  int got;
  initial begin
    kp = new();
    got = kp.fProp();
  end
endmodule
