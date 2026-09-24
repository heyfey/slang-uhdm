// r10uvm74 arm b3 — the CONTEXTS that share this builder, each of which owns a
// neighbouring law that this pass must not disturb:
//
//   c_stmt      STATEMENT position -- the flat method_func_call + Prefix arm
//               (`§ deepRecvCall11`'s statement form), which never builds a
//               hier_path at all.
//   c_with      an array-manipulation method carrying a `with` clause -- the
//               arm whose hier_path is named after the ARRAY ALONE and whose
//               every element takes a SCOPED fullname.
//   c_parenless a built-in written WITHOUT parens -- `§ parensLessCallIsPathRefObj`
//               (r10svs2), whose last element is a ref_obj and whose span runs
//               to the end of the method name.
//   c_user      a USER class method on an indexed receiver (not a built-in):
//               a different arm of emitExpr entirely.
//   c_read      the NON-CALL control: the same `q[i].member` written as a plain
//               read.  It already agrees with golden through
//               emitMixedHierPath, and it must still agree afterwards.
module b3;
  class item;
    string s;
    int    v;
    function int getv(); return v; endfunction
  endclass

  class user;
    item   iq[$];
    string sq[$];
    int    r;
    string t;

    function void f(int i);
      // c_stmt — statement position
      sq[i].itoa(3);
      // c_deeprecv — a built-in reached through an indexed base AND a member
      // step.  MISLABELLED `c_with` until integration: the line carries NO
      // `with` clause, so citing it as the with-clause cell would have been a
      // cited-guard-that-does-not-exist.  The GENUINE with form is c_withreal
      // (line 52), and it sits on a PLAIN receiver -- which is exactly why
      // README residue R2 says the with-clause + INDEX combination has NO
      // measured cell and is therefore fenced OUT of the law by `!withExpr9`.
      r = iq[i].s.len();
      // c_parenless — no argument list written
      r = sq[i].len;
      // c_user — a USER method through an indexed receiver
      r = iq[i].getv();
      // c_read — the NON-CALL control
      r = iq[i].v;
      t = iq[i].s;
    endfunction
  endclass

  class agg;
    int q[$];
    int r;
    function void g();
      // c_withreal — the genuine `with` form, on a plain (unindexed) receiver,
      // so the arm's own law is measured beside the indexed cells.
      r = q.sum() with (item);
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f(0);
  end
endmodule
