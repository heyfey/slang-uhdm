// r10v152 arm D — DECLARATOR COUNT, INITIALISERS, ARRAY SHAPES and MULTIPLE
// INSTANCES.  One package, several out-of-body constructors, each eating a
// differently shaped first declaration.
package shapepkg;

  class Nut; int nn; endclass

  class OneDecl;   int o1; extern function new(); endclass
  class TwoDecl;   int o2; extern function new(); endclass
  class ThreeDecl; int o3; extern function new(); endclass
  class InitDecl;  int o4; extern function new(); endclass
  class QueueDecl; int o5; extern function new(); endclass
  class DynDecl;   int o6; extern function new(); endclass
  class AssocDecl; int o7; extern function new(); endclass
  class FixedDecl; int o8; extern function new(); endclass
  class MixedKind; int o9; extern function new(); endclass

  function OneDecl::new();
    Nut solo;                       // d01 eaten, ONE declarator
    Nut after_solo;                 // d02
    solo = null; after_solo = null;
    o1 = 1;
  endfunction

  function TwoDecl::new();
    Nut duo_a, duo_b;               // d03/d04 eaten, TWO declarators, ONE decl
    Nut duo_c;                      // d05 second declaration -> local
    duo_a = null; duo_b = null; duo_c = null;
    o2 = 2;
  endfunction

  function ThreeDecl::new();
    Nut tri_a, tri_b, tri_c;        // d06/d07/d08 eaten, THREE declarators
    Nut tri_d;                      // d09
    tri_a = null; tri_b = null; tri_c = null; tri_d = null;
    o3 = 3;
  endfunction

  function InitDecl::new();
    Nut ini_a = null, ini_b = ini_a;   // d10/d11 eaten WITH initialisers
    Nut ini_c = null;                  // d12
    ini_a = null; ini_b = null; ini_c = null;
    o4 = 4;
  endfunction

  function QueueDecl::new();
    Nut qq[$];                      // d13 eaten, QUEUE of handles
    Nut qtail;                      // d14
    qtail = null;
    qq.push_back(qtail);            // d15 receiver
    o5 = 5;
  endfunction

  function DynDecl::new();
    Nut dd[];                       // d16 eaten, DYNAMIC array
    Nut dtail;
    dtail = null;
    dd = new[2];                    // d17
    o6 = 6;
  endfunction

  function AssocDecl::new();
    Nut aa[string];                 // d18 eaten, ASSOCIATIVE array
    Nut atail;
    atail = null;
    aa["k"] = atail;                // d19
    o7 = 7;
  endfunction

  function FixedDecl::new();
    Nut fa[3];                      // d20 eaten, FIXED unpacked array
    Nut ftail;
    ftail = null;
    fa[1] = ftail;                  // d21
    o8 = 8;
  endfunction

  function MixedKind::new();
    int mk_i;                       // d22 eaten, NON-class kind
    string mk_s;                    // d23
    Nut    mk_h;                    // d24
    mk_i = 1; mk_s = "x"; mk_h = null;
    o9 = 9;
  endfunction

endpackage

module mshape;
  import shapepkg::*;
  OneDecl a1, a2, a3;
  TwoDecl b1; ThreeDecl c1; InitDecl e1;
  QueueDecl f1; DynDecl g1; AssocDecl h1; FixedDecl i1; MixedKind j1;
  initial begin
    a1 = new(); a2 = new(); a3 = new();
    b1 = new(); c1 = new(); e1 = new();
    f1 = new(); g1 = new(); h1 = new(); i1 = new(); j1 = new();
  end
endmodule
