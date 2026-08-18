// r10buvm23repro/g23.sv — THE GOLDEN GRID for § dottedIdxRecvFromSyntax23.
//
// MEASUREMENT ONLY.  Compiled by Surelog (with and without -elabuhdm) and by
// both slang-uhdm binaries; `gridcmp23.py` scores every (view, owner, loc)
// cell three ways.  Nothing here is an acceptance judge.
//
// AXES
//   container   assoc[string] / assoc[int] / queue / dynamic / fixed
//   index       a method call on a handle `h.f()`; a member access `h.m`; a
//               nested select `b[i]`; a select through a member `h.a[i]`; a
//               STRING LITERAL WITH A DOT `"x.y"`; a concatenation; a ternary
//               with dots; a call with dotted arguments `f(h.m)`; an operation
//               with a dotted operand; a plain name (the CONTROL that must not
//               move)
//   trailing    .exists() / .delete() / .size() / .num() / a member / a
//               further index / nothing (parens-less) / a USER method
//   position    if condition / assignment Rhs / call argument / statement
//   home        class in-body / class out-of-body / package function / module
//
package p23;

  class h23;
    string       nm;
    int          ix;
    string       a23[4];
    function string f();  return nm;    endfunction
    function int    g();  return ix;    endfunction
  endclass

  function automatic string sf23(string s); return s; endfunction

  class c23;
    // ---- containers ----------------------------------------------------
    int    qa[string];              // assoc keyed by string
    int    qi[int];                 // assoc keyed by int
    int    qq[$];                   // queue
    int    qd[];                    // dynamic
    int    qf[4];                   // fixed
    int    q2[string][string];      // assoc of assoc
    h23    hq[string];              // assoc of class handles
    int    bidx[4];
    string skeys[4];

    // ---- EXPRESSION position, BUILT-IN trailing -------------------------
    function int e_call_exists(h23 hh);          // index = method call
      if (qa.exists(hh.f()) && (q2[hh.f()].exists(hh.f()))) return 1;
      return 0;
    endfunction
    function int e_call_size(h23 hh);
      return q2[hh.f()].size();
    endfunction
    function int e_call_num(h23 hh);
      return q2[hh.f()].num();
    endfunction
    function int e_memb_exists(h23 hh);          // index = member access
      if (q2[hh.nm].exists("k")) return 1;
      return 0;
    endfunction
    function int e_memb_size(h23 hh);
      return q2[hh.nm].size();
    endfunction
    function int e_sel_size(int i);              // index = nested select (NO dot)
      return q2[skeys[i]].size();
    endfunction
    function int e_membsel_size(h23 hh, int i);  // index = select THROUGH a member
      return q2[hh.a23[i]].size();
    endfunction
    function int e_lit_size();                   // index = string literal WITH a dot
      return q2["x.y"].size();
    endfunction
    function int e_cat_size(h23 hh);             // index = concatenation with dots
      return q2[{hh.nm, "z"}].size();
    endfunction
    function int e_tern_size(h23 hh, int c);     // index = ternary with dots
      return q2[c ? hh.nm : "z"].size();
    endfunction
    function int e_argcall_size(h23 hh);         // index = call with DOTTED args
      return q2[sf23(hh.nm)].size();
    endfunction
    function int e_oper_size(h23 hh, int i);     // index = operation w/ dotted operand
      return q2[skeys[i + hh.ix]].size();
    endfunction
    function int e_plain_size(string k);         // CONTROL: no dot at all
      return q2[k].size();
    endfunction
    function int e_qq_size(int i);               // CONTROL: queue, plain index
      return qq[i];
    endfunction

    // ---- EXPRESSION position, MEMBER / FURTHER INDEX / PARENS-LESS ------
    function string e_call_member(h23 hh);       // trailing MEMBER
      return hq[hh.f()].nm;
    endfunction
    function int e_call_index(h23 hh, string k); // trailing FURTHER INDEX
      return q2[hh.f()][k];
    endfunction
    function int e_call_parensless(h23 hh);      // trailing PARENS-LESS built-in
      return q2[hh.f()].size;
    endfunction
    function string e_call_usermeth(h23 hh);     // trailing USER method
      return hq[hh.f()].f();
    endfunction
    function int e_call_userparensless(h23 hh);  // trailing USER, parens-less
      return hq[hh.f()].ix;
    endfunction

    // ---- POSITIONS -----------------------------------------------------
    function int p_rhs(h23 hh);                  // assignment Rhs
      int r;
      r = q2[hh.f()].size();
      return r;
    endfunction
    function int p_arg(h23 hh);                  // call ARGUMENT
      return sf23($sformatf("%0d", q2[hh.f()].size())).len();
    endfunction
    task p_stmt_delete(h23 hh);                  // STATEMENT: delete WITH an arg
      q2[hh.f()].delete(hh.f());
    endtask
    task p_stmt_delete0(h23 hh);                 // STATEMENT: delete, NO arg
      q2[hh.f()].delete();
    endtask
    task p_stmt_user(h23 hh);                    // STATEMENT: USER method
      void'(hq[hh.f()].f());
    endtask
    function int p_cond(h23 hh);                 // if CONDITION
      if (q2[hh.f()].size() > 0) return 1;
      return 0;
    endfunction

    // ---- CONTAINER AXIS on the same index shape ------------------------
    function int c_assocint(h23 hh);  return qi[hh.g()];      endfunction
    function int c_queue(h23 hh);     return qq[hh.g()];      endfunction
    function int c_dyn(h23 hh);       return qd[hh.g()];      endfunction
    function int c_fixed(h23 hh);     return qf[hh.g()];      endfunction

    // ---- MULTI-DIMENSION / MULTI-COMPONENT -----------------------------
    function int m_twodim(h23 hh, string k);     // TWO written dimensions
      return q2[hh.f()][k];
    endfunction
    function int m_deep(h23 hh, int i);          // a DOTTED path with an indexed step
      return hq[hh.f()].a23[i].len();
    endfunction

    // ---- the OUT-OF-BODY twin ------------------------------------------
    extern function int o_call_size(h23 hh);
    extern task         o_stmt_delete(h23 hh);
  endclass

  function int c23::o_call_size(h23 hh);
    return q2[hh.f()].size();
  endfunction
  task c23::o_stmt_delete(h23 hh);
    q2[hh.f()].delete(hh.f());
  endtask

  // ---- PACKAGE-scope function ------------------------------------------
  int pq2[string][string];
  function automatic int pk_call_size(h23 hh);
    return pq2[hh.f()].size();
  endfunction
  function automatic int pk_memb_size(h23 hh);
    return pq2[hh.nm].size();
  endfunction
  task automatic pk_stmt_delete(h23 hh);
    pq2[hh.f()].delete(hh.f());
  endtask
endpackage

module g23top;
  import p23::*;
  int mq2[string][string];
  h23 mh;
  int mres;

  function automatic int md_call_size(h23 hh);
    return mq2[hh.f()].size();
  endfunction
  function automatic int md_memb_size(h23 hh);
    return mq2[hh.nm].size();
  endfunction
  task automatic md_stmt_delete(h23 hh);
    mq2[hh.f()].delete(hh.f());
  endtask

  initial begin
    mres = md_call_size(mh);
    if (mq2[mh.f()].exists(mh.nm)) mres = 1;
    mq2[mh.f()].delete(mh.f());
    mres = mq2[mh.nm].size();
  end
endmodule
