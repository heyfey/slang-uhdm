// r10v191 ADVERSARIAL ARM D — THE RETURN-NAME AXIS and the DEEP PATH.
//
// r10uvm191's shipped hop makes `ownerTf9` succeed for objects written inside
// a dynamic-array `new[...]` argument in a wildcard-import clone listing.
// That opens the whole `pkgCloneHierBind9` pass — `bind9`, § pkgCloneMember10
// and § builtinArrayReadBindsMintedFuncCall182 — on a window that was
// previously invisible to all three.  Arms A/B/C measured the receiver kinds,
// the declaring scopes and the surrounding contexts.  NEITHER measured the
// one spelling the standing law § retNameArgKeepsReturnVar184v protects: a
// subroutine's OWN RETURN NAME, and neither measured a path DEEPER than two
// elements or the § 184 / R2 argument faces INSIDE the window.
//
// Rows:
//   D1..D4  the RETURN NAME as the hier_path BASE under `new[...]`, for a
//           free `automatic` function, a free STATIC function, an
//           OUT-OF-BODY class method and an IN-BODY class method.
//   D5..D6  the RETURN NAME as a direct ARGUMENT of a built-in STRING method
//           written INSIDE the window (§ cloneBuiltinMethodArgBindsReceiver184
//           and its § retNameArgKeepsReturnVar184v exception).
//   D7      an ARRAY receiver's built-in method argument inside the window
//           (r10uvm184's R2 family, the pass's own new head).
//   D8..D9  a THREE-element path and a FOUR-element path under `new[...]`.
//   D10     a path whose base is a FORMAL struct and whose second element is
//           a queue, read parens-less (the § 182 face at depth 2).
//
// Names, numbers and orders are deliberately unlike the corpus' and unlike
// arms A/B/C.
package Mullion191;

  typedef struct {
    int    ferrule191;
    int    spline191[$];
  } Gudgeon191;

  typedef struct {
    Gudgeon191 inner191;
    int        capstan191;
  } Trunnion191;

  typedef int Skeg191[];

  int gaff191[string];

  class Batten191;
    int m_clew191[];
    extern function Skeg191 luff191(input int fml_p);
    // IN BODY — a class method that is never lifted out.
    function Skeg191 leech191(input int fml_q);
      int tack191[$];
      tack191.push_back(fml_q);
      leech191 = new[tack191.size()];
      // D4  the RETURN NAME as a hier_path BASE, in-body class method
      leech191 = new[leech191.size()];
      return leech191;
    endfunction
  endclass

  // OUT OF BODY — the corpus face.
  function Skeg191 Batten191::luff191(input int fml_p);
    int        parrel191[$];
    Trunnion191 rig191;
    string     hawser191;
    int        visited191[int];
    int        succ191;

    parrel191.push_back(fml_p);
    rig191.inner191.spline191.push_back(2);
    rig191.capstan191 = 3;
    hawser191 = "windlass";
    visited191[7] = 8;
    succ191 = 7;

    luff191 = new[parrel191.size()];
    // D3  the RETURN NAME as a hier_path BASE, OUT-OF-BODY class method —
    //     REMOVED: Surelog itself rejects this spelling
    //     (`[ERR:UH0725] Unresolved hierarchical reference "luff191.size"`),
    //     so the face has NO GOLDEN to measure against and is a residue, not
    //     a cell.  Our two binaries both accept it with rc=0.
    // D8  a THREE-element path under new[]
    luff191 = new[rig191.inner191.spline191.size()];
    // D9  a FOUR-element path is not spellable past a queue; the deepest
    //     legal read is the parens-less size of the nested queue.
    luff191 = new[rig191.inner191.spline191.size];
    // D7  an ARRAY receiver's built-in method ARGUMENT inside the window
    //     (r10uvm184's R2 family)
    luff191 = new[visited191.exists(succ191)];
    // D5  a direct argument of a built-in STRING method, inside the window
    //     (§ cloneBuiltinMethodArgBindsReceiver184's own face, now written
    //     under `new[...]`).  The RETURN-NAME variant of this cell is the
    //     same Surelog-rejected spelling as D3, so the argument here is a
    //     plain local.
    luff191 = new[hawser191.getc(fml_p) + parrel191.size()];
    return luff191;
  endfunction

  // A FREE `automatic` package function — § retNameArgKeepsReturnVar184v's
  // own cell, now written INSIDE the window.
  function automatic Skeg191 rudder191(input int fml_r);
    int    stay191[$];
    string cordage191;
    int    idx191;

    stay191.push_back(fml_r);
    cordage191 = "boomkin";
    idx191 = 1;

    rudder191 = new[stay191.size()];
    // D1  the RETURN NAME as a hier_path BASE, free automatic function
    rudder191 = new[rudder191.size()];
    // D6  the RETURN NAME as a direct argument of a built-in STRING method,
    //     inside the window — the FREE-function cell the standing law says
    //     keeps § 171's RETURN VARIABLE and must NOT take the receiver
    rudder191 = new[cordage191.getc(idx191) + rudder191.size()];
    return rudder191;
  endfunction

  // A free STATIC package function at the same face.
  function Skeg191 transom191(input int fml_s);
    int keel191[$];
    keel191.push_back(fml_s);
    transom191 = new[keel191.size()];
    // D2  the RETURN NAME as a hier_path BASE, free STATIC function
    transom191 = new[transom191.size()];
    return transom191;
  endfunction

  // D10  a FORMAL struct base, second element a queue, read PARENS-LESS.
  function automatic Skeg191 gunwale191(input Gudgeon191 fml_t);
    Skeg191 out191;
    out191 = new[fml_t.spline191.size];
    return out191;
  endfunction

endpackage

// WILDCARD import — the clone listing this law owns.
package Bowsprit191;
  import Mullion191::*;
  int drift191 = 21;
  function automatic int use_bow191();
    Batten191  bt191;
    Gudgeon191 gd191;
    Skeg191    s1191;
    Skeg191    s2191;
    Skeg191    s3191;
    Skeg191    s4191;
    Skeg191    s5191;
    bt191 = new();
    gd191.ferrule191 = 1;
    gd191.spline191.push_back(2);
    s1191 = bt191.luff191(3);
    s2191 = bt191.leech191(4);
    s3191 = rudder191(5);
    s4191 = transom191(6);
    s5191 = gunwale191(gd191);
    return s1191.size() + s2191.size() + s3191.size() + s4191.size() +
           s5191.size() + drift191 + gaff191.size();
  endfunction
endpackage

module top191d;
  import Bowsprit191::*;
  int scored191;
  initial begin
    scored191 = use_bow191();
    $display("%0d", scored191);
  end
endmodule
