// r10v171 arm B — THE LISTING FACES the brief names, all in ONE home package
// that a clone importer wildcard-imports.  Every function touches its own
// return name in a select and/or a method-receiver position so the patch's
// four mint sites are live on every face.
//
// Faces: leading declaration block / declarations inside a named begin /
// declarations AFTER the first statement / interleaved; the return name
// assigned vs read vs never used vs shadowed; void function and task;
// automatic and static; nested begins each with locals; a function whose only
// local is the return-typed one.
package faces_home_171;

  // F1 — LEADING declaration block, return name assigned then selected.
  function string f_lead();
    int ka;
    byte bb;
    f_lead = "leading";
    ka = f_lead.len() - 1;
    bb = f_lead[ka];
    f_lead[0] = bb;
  endfunction

  // F2 — declarations INSIDE a NAMED BEGIN (the block owns the listing).
  function string f_named();
    f_named = "named";
    begin : nb171
      int kb;
      byte bc;
      kb = f_named.len() - 1;
      bc = f_named[kb];
      f_named[0] = bc;
    end
  endfunction

  // F3 — declaration AFTER the first statement is illegal in a plain body, so
  //      the legal spelling of "mid-body decl" is a nested unnamed begin.
  function string f_mid();
    f_mid = "mid";
    begin
      int kc;
      kc = f_mid.len();
      if (kc > 0) f_mid[0] = "M";
    end
  endfunction

  // F4 — NESTED BEGINS, each with its own locals, the return name selected at
  //      every depth.
  function string f_nest();
    int k0;
    f_nest = "nest";
    k0 = f_nest.len();
    begin : n1
      int k1;
      k1 = f_nest.len() - 1;
      f_nest[0] = "N";
      begin : n2
        int k2;
        k2 = f_nest.len() - 2;
        f_nest[1] = "E";
        begin : n3
          int k3;
          k3 = f_nest.len() - 3;
          f_nest[2] = "S";
          if (k3 + k2 + k1 + k0 == 0) f_nest = "";
        end
      end
    end
  endfunction

  // F5 — the return name is READ ONLY (never assigned) in a select position.
  function string f_readonly();
    byte br;
    br = f_readonly[0];
    if (br == 0) br = 1;
  endfunction

  // F6 — a function whose ONLY local is the return-typed one.
  function string f_onlyret();
    f_onlyret = "only";
    f_onlyret[0] = "O";
  endfunction

  // F7 — AUTOMATIC subroutine.
  function automatic string f_auto();
    int kg;
    f_auto = "auto";
    kg = f_auto.len() - 1;
    f_auto[0] = f_auto[kg];
  endfunction

  // F8 — STATIC subroutine.
  function static string f_static();
    int kh;
    f_static = "static";
    kh = f_static.len() - 1;
    f_static[0] = f_static[kh];
  endfunction

  // F9 — VOID function: there is no return name; the same spellings on a
  //      LOCAL must not move.
  function void f_void();
    string sv;
    int kv;
    sv = "void";
    kv = sv.len() - 1;
    sv[0] = sv[kv];
  endfunction

  // F10 — TASK: same, no return name.
  task f_task();
    string st;
    int kt;
    st = "task";
    kt = st.len() - 1;
    st[0] = st[kt];
  endtask

  // F11 — the return name SHADOWED by a same-spelled local inside a named
  //       begin.  The mint sites key on the SYMBOL, not on the name text, so
  //       nothing here may bind to the home return.
  function string f_shadow();
    f_shadow = "outer";
    begin : sb171
      string f_shadow;
      int ks;
      f_shadow = "inner";
      ks = f_shadow.len() - 1;
      f_shadow[0] = f_shadow[ks];
      if (ks < 0) ks = 0;
    end
  endfunction

  // F12 — a DEEPER method-receiver chain (dots.size() > 1): the site is gated
  //       on a ONE-NAME receiver, so this must stay exactly as pristine.
  function string f_deep();
    int kd;
    f_deep = "deepdeep";
    kd = f_deep.substr(0, 3).len();
    if (kd == 0) f_deep[0] = "D";
  endfunction
endpackage

// THREE importers of the same home package — three clones of every body.
package faces_c1_171;
  import faces_home_171::*;
  function int c1_use();
    return f_lead().len() + f_named().len() + f_mid().len();
  endfunction
endpackage

package faces_c2_171;
  import faces_home_171::*;
  function int c2_use();
    return f_nest().len() + f_readonly().len() + f_onlyret().len();
  endfunction
endpackage

package faces_c3_171;
  import faces_home_171::*;
  function int c3_use();
    int rr;
    rr = f_auto().len() + f_static().len() + f_shadow().len() + f_deep().len();
    f_void();
    return rr;
  endfunction
  task c3_tk();
    f_task();
  endtask
endpackage

module faces_top_171;
  import faces_c1_171::*;
  import faces_c2_171::*;
  import faces_c3_171::*;
  int fr;
  initial begin
    fr = c1_use() + c2_use() + c3_use();
    c3_tk();
  end
endmodule
