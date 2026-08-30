// r10uvm166 GRID C -- THE GATE ARM.  MEASUREMENT ONLY.
// The two teeth of the decode:
//   (i)  the typedef's BASE is written as a NAME (slStringConst / Owner::name)
//        vs as a KEYWORD / an INLINE enum-struct-union;
//   (ii) the typedef's HOME is a PACKAGE or $unit (where Surelog DOES build the
//        typespec, unless the base resolves to a class or to nothing) vs a
//        class / module / interface / program (where it never does).
typedef int unitBase166_t;
typedef unitBase166_t unitNameQ166_t[$];
typedef int           unitKeyQ166_t[$];

package sk166;
  class Bale166;  int tag166; endclass
  typedef enum { ONE166, TWO166 } chime166_e;
  typedef struct packed { bit [1:0] a166; bit [1:0] b166; } pair166_s;
  typedef int    plain166_t;
  class Fwd166;  endclass

  typedef chime166_e  pEnumQ166_t[$];      // NAME base, package home, enum
  typedef pair166_s   pStrQ166_t[$];       // NAME base, package home, struct
  typedef plain166_t  pTdQ166_t[$];        // NAME base, package home, int td
  typedef Bale166     pClsQ166_t[$];       // NAME base, package home, CLASS
  typedef int         pKeyQ166_t[$];       // KEYWORD base, package home
  typedef string      pStrKeyQ166_t[$];    // KEYWORD base, package home
  typedef enum { RED166, BLUE166 } pInlEnumQ166_t[$];       // INLINE enum
  typedef struct packed { bit c166; bit d166; } pInlStrQ166_t[$]; // INLINE struct

  function void rake166();
    pEnumQ166_t   pEnumVal166;
    pStrQ166_t    pStrVal166;
    pTdQ166_t     pTdVal166;
    pClsQ166_t    pClsVal166;
    pKeyQ166_t    pKeyVal166;
    pStrKeyQ166_t pStrKeyVal166;
    pInlEnumQ166_t pInlEnumVal166;
    pInlStrQ166_t  pInlStrVal166;
  endfunction

  class Barn166;
    typedef chime166_e cEnumQ166_t[$];     // NAME base, CLASS home
    typedef int        cKeyQ166_t[$];      // KEYWORD base, CLASS home
    typedef enum { GO166, STOP166 } cInlEnumQ166_t[$];
    typedef sk166::plain166_t cScopedQ166_t[$];   // Owner::name base
    function void sweep166();
      cEnumQ166_t    cEnumVal166;
      cKeyQ166_t     cKeyVal166;
      cInlEnumQ166_t cInlEnumVal166;
      cScopedQ166_t  cScopedVal166;
    endfunction
  endclass
endpackage

module bay166;
  import sk166::*;
  typedef chime166_e mEnumQ166_t[$];       // NAME base, MODULE home
  typedef int        mKeyQ166_t[$];        // KEYWORD base, MODULE home
  typedef enum { UP166, DOWN166 } mInlEnumQ166_t[$];
  function automatic void stack166();
    mEnumQ166_t    mEnumVal166;
    mKeyQ166_t     mKeyVal166;
    mInlEnumQ166_t mInlEnumVal166;
    unitNameQ166_t uNameVal166;
    unitKeyQ166_t  uKeyVal166;
  endfunction
  initial stack166();
endmodule

interface span166;
  import sk166::*;
  typedef chime166_e iEnumQ166_t[$];
  typedef int        iKeyQ166_t[$];
  function automatic void lace166();
    iEnumQ166_t iEnumVal166;
    iKeyQ166_t  iKeyVal166;
  endfunction
endinterface

program pace166;
  import sk166::*;
  typedef chime166_e gEnumQ166_t[$];
  typedef int        gKeyQ166_t[$];
  task automatic knit166();
    gEnumQ166_t gEnumVal166;
    gKeyQ166_t  gKeyVal166;
  endtask
  initial knit166();
endprogram
