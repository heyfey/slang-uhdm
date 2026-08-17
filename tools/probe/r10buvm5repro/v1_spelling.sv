// vbuvm5 ADVERSARIAL arm v1 -- BLOCK-SCOPE DECLARATIONS IN EVERY SPELLING.
//
// The implementer's law (§ refVarLocalWindowBinds5) says: a reference to a
// subroutine-local whose emitted declaration is a `ref_var` binds its vpiActual
// ONLY when (a) it stands in an if/case CONDITION or a USER call's ARGUMENT
// list, and (b) its declaration sits at the same ctrlBodyDepth28 the reference
// reads at.
//
// Every cell here is a SPELLING the implementer's two arms did not measure.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The `ref_var` population is: a class-nested typedef spelled BARE inside an
// OUT-OF-BODY (extern) method definition (EmitHelpers.h grid g6 `v_ext_bare`).
package qv;

  class boxv #(type Tv = int);
    Tv vv;
  endclass

  typedef boxv #(int) biv_t;

  class plainv;
    int kv;
    function int getv(); return kv; endfunction
  endclass

  class ownv;
    typedef struct packed { int av; } recv_t;   // class-nested, bare-spelled
    protected biv_t holdv[$];
    protected int   numsv[$];
    protected int   mv;

    extern function void k01v(int nv);
    extern function biv_t k02v(int nv);
    extern function void k03v(int nv);
    extern function void k04v(int nv);
    extern function void k05v(int nv);
    extern function void k06v(int nv);
    extern function void k07v(int nv);
    extern function void k08v(int nv);
    extern function void k09v(int nv);
    extern function void k10v(int nv);

    extern function void k12v(int nv);
    extern function void k13v(int nv);
    extern function void k14v(int nv);
    extern function void k15v(int nv);
    extern function void k16v(int nv);
    extern function void k17v(int nv);
    extern function void k18v(int nv);
    extern function void k19v(int nv);
    extern function void k20v(int nv);
    extern task         k21v(int nv);
    extern function void k22v(int nv);
  endclass

  function void sinkv(biv_t av); endfunction
  function void isinkv(int av); endfunction

  // k01 -- `return v;` of the ref_var itself.  NOT an if/case condition and not
  // a call argument, so the law says BARE.  Never measured by a1/a2.
  function biv_t ownv::k02v(int nv);
    biv_t vv;
    return vv;
  endfunction

  // k01 -- the ref_var as a call argument inside a RETURN expression
  function void ownv::k01v(int nv);
    biv_t vv;
    holdv.push_back(vv);              // control: stmt call arg, d0 -> BIND
  endfunction

  // k03 -- the ref_var as the RECEIVER of a method call (not an argument)
  function void ownv::k03v(int nv);
    plainv pv;
    biv_t  vv;
    numsv.push_back(vv.vv);           // receiver of a member select, d0
  endfunction

  // k04 -- $cast as a STATEMENT (a1 P7 measured $cast only INSIDE a condition)
  function void ownv::k04v(int nv);
    biv_t vv;
    plainv pv;
    void'($cast(vv, pv));
  endfunction

  // k05 -- an ELSE-IF condition.  slang models `else if` as a nested
  // ConditionalStatement inside the else arm, so ctrlBodyDepth28 is 1 there
  // while the source reads like one flat chain.
  function void ownv::k05v(int nv);
    biv_t vv;
    if (nv == 0) numsv.push_back(1);
    else if (vv == null) numsv.push_back(2);
    else numsv.push_back(3);
  endfunction

  // k06 -- the ELSE arm's bare body, call arg (d1)
  function void ownv::k06v(int nv);
    biv_t vv;
    if (nv == 0) numsv.push_back(1);
    else sinkv(vv);
  endfunction

  // k07 -- FOREACH body, call arg
  function void ownv::k07v(int nv);
    biv_t vv;
    foreach (numsv[iv]) sinkv(vv);
  endfunction

  // k08 -- DO-WHILE condition (a2 b04 measured `while` only)
  function void ownv::k08v(int nv);
    biv_t vv;
    do nv = nv + 1; while (vv == null);
  endfunction

  // k09 -- REPEAT body, call arg
  function void ownv::k09v(int nv);
    biv_t vv;
    repeat (nv) sinkv(vv);
  endfunction

  // k10 -- FOREVER body with a break, call arg
  function void ownv::k10v(int nv);
    biv_t vv;
    forever begin
      sinkv(vv);
      break;
    end
  endfunction

  // k11 -- FORK ARM at depth 0: decl in the function, read in the arm.
  // § 64's b4 e9 says a fork arm inside an `if` does NOT raise ctrlBodyDepth28.
  task ownv::k21v(int nv);
    biv_t vv;
    fork
      sinkv(vv);
    join
  endtask

  // k12 -- decl INSIDE a fork arm, read in that same arm
  function void ownv::k12v(int nv);
    fork
      begin
        biv_t vv;
        sinkv(vv);
      end
    join_none
  endfunction

  // k13 -- declaration WITH INITIALIZER; the initializer names another ref_var
  function void ownv::k13v(int nv);
    biv_t wv;
    biv_t vv = wv;                    // wv read in an INITIALIZER, d0
    sinkv(vv);
  endfunction

  // k14 -- an UNUSED ref_var local (nothing must change about the decl)
  function void ownv::k14v(int nv);
    biv_t vv;
    numsv.push_back(nv);
  endfunction

  // k15 -- CASE ITEM statement (d1) vs the case EXPRESSION (d0)
  function void ownv::k15v(int nv);
    biv_t vv;
    case (nv)
      0: sinkv(vv);                   // case ITEM body, d1
      default: numsv.push_back(1);
    endcase
  endfunction

  // k16 -- the ref_var as a CASE ITEM EXPRESSION (not the case expression)
  function void ownv::k16v(int nv);
    biv_t vv;
    biv_t uv;
    case (vv)                         // case expr, d0 -> BIND (a2 b03)
      uv: numsv.push_back(1);         // case ITEM expression, d0
      default: numsv.push_back(2);
    endcase
  endfunction

  // k17 -- UNIQUE IF / PRIORITY IF condition (the `ie` arm of the patch)
  function void ownv::k17v(int nv);
    biv_t vv;
    unique if (vv == null) numsv.push_back(1);
    else numsv.push_back(2);
  endfunction

  // k18 -- ternary CONDITION in an assignment (not a window)
  function void ownv::k18v(int nv);
    biv_t vv;
    mv = (vv == null) ? 1 : 0;
  endfunction

  // k19 -- NESTED unnamed begin whose OWN local is read in a condition at the
  // same depth, alongside the outer function local read at that same depth
  function void ownv::k19v(int nv);
    biv_t ov;
    begin
      biv_t iv;
      if (iv == null) numsv.push_back(1);   // block local, d0 == d0 -> BIND
      if (ov == null) numsv.push_back(2);   // fn local, d0 == d0    -> BIND
    end
  endfunction

  // k20 -- STATIC vs AUTOMATIC lifetime on the local
  function automatic void ownv::k20v(int nv);
    biv_t vv;
    sinkv(vv);
    if (vv == null) numsv.push_back(1);
  endfunction

  // k22 -- a ref_var read from a NAMED begin nested in an if (named + depth)
  function void ownv::k22v(int nv);
    biv_t vv;
    if (nv == 0) begin : nmv
      sinkv(vv);
    end
  endfunction

endpackage
