// vbuvm5 ADVERSARIAL arm v3 -- MORE WINDOW SHAPES around the case/if family,
// after arm v1 found the CASE ITEM EXPRESSION regression (k16).
//
// The patch raises its condition window at exactly three StmtEmit sites: the
// unique/priority `if`, the plain `if`, and the `case` CONDITION.  Everything
// else in the if/case family is left outside the window.  These cells ask
// whether golden's window is really only those three, and -- crucially -- what
// the DEPTH rule is for a case ITEM expression.
package qw;

  class boxw #(type Tw = int);
    Tw vw;
  endclass
  typedef boxw #(int) biw_t;

  class ownw;
    typedef logic [7:0] bw_t;          // integral ref_var, for casex/casez
    protected biw_t holdw[$];
    protected int   numsw[$];
    protected int   mw;

    extern function void w01w(int nw);
    extern function void w02w(int nw);
    extern function void w03w(int nw);
    extern function void w04w(int nw);
    extern function void w05w(int nw);
    extern function void w06w(int nw);
    extern function void w07w(int nw);
    extern function void w08w(int nw);
    extern function void w09w(int nw);
    extern function void w10w(int nw);
    extern function void w11w(int nw);
    extern function void w12w(int nw);
    extern function void w13w(int nw);
  endclass

  function void sinkw(biw_t aw); endfunction
  function int  fnw(biw_t aw); return 0; endfunction

  // w01 -- case item with MULTIPLE expressions
  function void ownw::w01w(int nw);
    biw_t vw;
    biw_t uw;
    case (vw)
      uw, vw: numsw.push_back(1);
      default: numsw.push_back(2);
    endcase
  endfunction

  // w02 -- CASEX item expression (integral ref_var)
  function void ownw::w02w(int nw);
    bw_t vw;
    bw_t uw;
    casex (vw)
      uw: numsw.push_back(1);
      default: numsw.push_back(2);
    endcase
  endfunction

  // w03 -- CASEZ item expression (integral ref_var)
  function void ownw::w03w(int nw);
    bw_t vw;
    bw_t uw;
    casez (vw)
      uw: numsw.push_back(1);
      default: numsw.push_back(2);
    endcase
  endfunction

  // w04 -- UNIQUE CASE item expression
  function void ownw::w04w(int nw);
    biw_t vw;
    biw_t uw;
    unique case (vw)
      uw: numsw.push_back(1);
      default: numsw.push_back(2);
    endcase
  endfunction

  // w05 -- a case ITEM EXPRESSION one control body DEEPER than the decl
  function void ownw::w05w(int nw);
    biw_t vw;
    biw_t uw;
    if (nw == 0) begin
      case (vw)
        uw: numsw.push_back(1);
        default: numsw.push_back(2);
      endcase
    end
  endfunction

  // w06 -- a case ITEM EXPRESSION whose case sits at depth 1 but whose decl is
  // in that same block (d1 == d1)
  function void ownw::w06w(int nw);
    if (nw == 0) begin
      biw_t vw;
      biw_t uw;
      case (vw)
        uw: numsw.push_back(1);
        default: numsw.push_back(2);
      endcase
    end
  endfunction

  // w07 -- an IMMEDIATE ASSERTION condition
  function void ownw::w07w(int nw);
    biw_t vw;
    assert (vw != null) numsw.push_back(1);
  endfunction

  // w08 -- residue R1 shape: a USER call nested INSIDE a condition
  function void ownw::w08w(int nw);
    biw_t vw;
    if (fnw(vw) == 0) numsw.push_back(1);
  endfunction

  // w09 -- an IF condition nested inside a CASE ITEM at the same decl depth
  function void ownw::w09w(int nw);
    biw_t vw;
    case (nw)
      0: if (vw == null) numsw.push_back(1);   // d1
      default: numsw.push_back(2);
    endcase
  endfunction

  // w10 -- an ELSE arm block whose own local is read in an if condition there
  function void ownw::w10w(int nw);
    if (nw == 0) numsw.push_back(1);
    else begin
      biw_t vw;
      if (vw == null) numsw.push_back(2);      // decl d1, read d1
    end
  endfunction

  // w11 -- the ref_var on BOTH sides of a condition
  function void ownw::w11w(int nw);
    biw_t vw;
    biw_t uw;
    if (vw == uw) numsw.push_back(1);
  endfunction

  // w12 -- ref_var in a statement call arg and in an ASSIGNMENT-RHS call arg
  function void ownw::w12w(int nw);
    biw_t vw;
    sinkw(vw);
    mw = fnw(vw);
  endfunction

  // w13 -- case ITEM EXPRESSION where the item is a CONCATENATION / operation
  function void ownw::w13w(int nw);
    bw_t vw;
    bw_t uw;
    case (vw)
      (uw + 1): numsw.push_back(1);
      default: numsw.push_back(2);
    endcase
  endfunction

endpackage
