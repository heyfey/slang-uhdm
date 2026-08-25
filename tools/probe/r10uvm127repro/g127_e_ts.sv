// r10uvm127 grid E — TYPESPEC KINDS x FORMAL DIRECTIONS x ACTUAL SHAPES, all
// inside the out-of-body window this pass opens.  Every callee is a DPI-C
// import, or an SV function whose own body reaches one, so no call folds away.
// MEASUREMENT ONLY.
package Windlass;
  typedef enum int { MOTE_A = 3, MOTE_B = 11 } mote_e;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } nib_t;
  typedef logic [11:0] dozen_t;

  class Cornice;
    int    prop9   = 5;
    string propTxt = "px";
  endclass

  // callees, one per typespec kind
  import "DPI-C" function int tsString (string  s1);
  import "DPI-C" function int tsInt    (int     i1);
  import "DPI-C" function int tsByte   (byte    b1);
  import "DPI-C" function int tsLogic  (logic [11:0] l1);
  import "DPI-C" function int tsEnum   (mote_e  e1);
  import "DPI-C" function int tsStruct (nib_t   n1);
  import "DPI-C" function int tsTypedef(dozen_t d1);
  import "DPI-C" function int tsReal   (real    r1);
  import "DPI-C" function int tsTwo    (int a1, string a2);
  import "DPI-C" function int tsOutDpi (output int o1);
  import "DPI-C" function int tsInoutDpi(inout int io1);

  // a CLASS-handle formal is not DPI-legal: an SV wrapper whose body reaches a
  // DPI import keeps the call unfoldable all the same
  function automatic int tsClass (Cornice c1);
    return tsInt(c1.prop9);
  endfunction
  function automatic int dirRef (ref int r1);
    r1 = tsInt(r1);
    return r1;
  endfunction

  class Bulwark;
    int      ownProp = 7;
    Cornice  ownObj;
    dozen_t  ownVec;
    extern function int kString (string s1);
    extern function int kInt    (int i1);
    extern function int kByte   (byte b1);
    extern function int kLogic  (logic [11:0] l1);
    extern function int kEnum   (mote_e e1);
    extern function int kStruct (nib_t n1);
    extern function int kTypedef(dozen_t d1);
    extern function int kClass  (Cornice c1);
    extern function int kReal   (real r1);
    extern function int kOut    ();
    extern function int kInout  ();
    extern function int kRef    ();
    extern function int kProp   ();
    extern function int kSelect ();
    extern function int kMember ();
    extern function int kLit    ();
    extern function int kOper   (int i1);
  endclass

  function int Bulwark::kString (string s1);        return tsString(s1);   endfunction
  function int Bulwark::kInt    (int i1);           return tsInt(i1);      endfunction
  function int Bulwark::kByte   (byte b1);          return tsByte(b1);     endfunction
  function int Bulwark::kLogic  (logic [11:0] l1);  return tsLogic(l1);    endfunction
  function int Bulwark::kEnum   (mote_e e1);        return tsEnum(e1);     endfunction
  function int Bulwark::kStruct (nib_t n1);         return tsStruct(n1);   endfunction
  function int Bulwark::kTypedef(dozen_t d1);       return tsTypedef(d1);  endfunction
  function int Bulwark::kClass  (Cornice c1);       return tsClass(c1);    endfunction
  function int Bulwark::kReal   (real r1);          return tsReal(r1);     endfunction
  function int Bulwark::kOut    ();
    int spare;
    return tsOutDpi(spare);                      // OUTPUT formal
  endfunction
  function int Bulwark::kInout  ();
    int spare = 1;
    return tsInoutDpi(spare);                    // INOUT formal
  endfunction
  function int Bulwark::kRef    ();
    int spare = 2;
    return dirRef(spare);                        // REF formal
  endfunction
  function int Bulwark::kProp   ();
    return tsInt(ownProp);                       // a CLASS PROPERTY actual
  endfunction
  function int Bulwark::kSelect ();
    return tsByte(ownVec[3:0]);                  // a PART-SELECT actual
  endfunction
  function int Bulwark::kMember ();
    return tsInt(ownObj.prop9);                  // a hier_path actual (fence)
  endfunction
  function int Bulwark::kLit    ();
    return tsTwo(41, "seventeen");               // CONSTANT actuals
  endfunction
  function int Bulwark::kOper   (int i1);
    return tsTwo(i1 + 2, "eleven");              // an OPERATION actual
  endfunction
endpackage

module Windlass_top;
  import Windlass::*;
  Bulwark unit1;
  int got;
  initial begin
    unit1 = new();
    got = unit1.kInt(4);
  end
endmodule
