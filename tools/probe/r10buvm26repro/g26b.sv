// r10buvm26 grid B — the DROPPED-CALL family (§ droppedCall14): a method call
// whose RECEIVER's type is an UNSPECIALIZED type PARAMETER, so slang binds no
// member and hands back an InvalidExpression whose child is the receiver.
// Every cell here is INSIDE a parameterized class whose DEFAULT type argument
// does NOT declare the method, which is the only way to reach that state
// without a hard slang error.  MEASUREMENT ONLY.
package q29;

  class base29;
    int v;
  endclass

  // the type argument every REAL specialization uses — it HAS the method, so
  // the specialized copies bind and only the DEFAULT specialization (the DEF
  // listing) reaches the dropped-call state.  This is uvm_port_component's own
  // arrangement: `#(type PORT=uvm_object)` with every use passing a port type.
  class rich29 extends base29;
    function int get_comp(); return v; endfunction
    function int get_comp1(int k); return v + k; endfunction
    function int get_comp2(int a, int b); return v + a + b; endfunction
    function rich29 self29(); return this; endfunction
  endclass

  typedef int lst29[string];

  class dc29 #(type PORT = base29);

    PORT      as29[string];   // associative, string-keyed
    PORT      qu29[$];        // queue
    PORT      dy29[];         // dynamic
    PORT      fx29[4];        // fixed unpacked
    PORT      aa29[string][string];
    PORT      h29;            // plain handle (the § droppedCall14 shape)
    int       ix29;
    string    sk29;

    // --- EXPRESSION position, assignment RHS ------------------------------
    function void e1(ref lst29 lst, string nm);   // THE HEAD SHAPE
      lst[nm] = as29[nm].get_comp();
    endfunction
    function void e2(ref lst29 lst, string nm, int x);
      lst[nm] = as29[nm].get_comp1(x);
    endfunction
    function void e3(ref lst29 lst, string nm, int a);
      lst[nm] = as29[nm].get_comp2(a, h29.v);
    endfunction
    function void e4(ref lst29 lst);              // INTEGER-LITERAL index
      lst["z"] = qu29[0].get_comp();
    endfunction
    function void e5(ref lst29 lst);              // STRING-LITERAL index
      lst["z"] = as29["k"].get_comp();
    endfunction
    function void e6(ref lst29 lst, int i);       // OPERATION index
      lst["z"] = qu29[i + 1].get_comp();
    endfunction
    function void e7(ref lst29 lst, string nm);   // MEMBER index
      lst[nm] = as29[sk29].get_comp();
    endfunction
    function void e8(ref lst29 lst, int i);       // dynamic-array receiver
      lst["z"] = dy29[i].get_comp();
    endfunction
    function void e9(ref lst29 lst, int i);       // fixed-array receiver
      lst["z"] = fx29[i].get_comp();
    endfunction
    function void e10(ref lst29 lst, string nm);  // TWO subscripts
      lst[nm] = aa29[nm][nm].get_comp();
    endfunction
    function void e11(ref lst29 lst, string nm);  // plain handle (control)
      lst[nm] = h29.get_comp();
    endfunction
    function int e12(string nm);                  // RETURN position
      return as29[nm].get_comp();
    endfunction
    function void e13(string nm);                 // CONDITION position
      if (as29[nm].get_comp()) ix29 = 1;
    endfunction
    function void e14(string nm);                 // SYSTEM-CALL argument
      $display("%0d", as29[nm].get_comp());
    endfunction
    function void e15(ref lst29 lst, string nm);  // OPERAND of an operation
      lst[nm] = as29[nm].get_comp() + 1;
    endfunction
    function void e16(ref lst29 lst, string nm);  // trailing MEMBER of a call
      lst[nm] = as29[nm].self29().v;
    endfunction
    function void e17(ref lst29 lst, string nm);  // LHS is a plain scalar
      ix29 = as29[nm].get_comp();
    endfunction
    function void e18(ref lst29 lst, string nm);  // compound assignment
      lst[nm] += as29[nm].get_comp();
    endfunction

    // --- STATEMENT position ------------------------------------------------
    function void s1(string nm);
      as29[nm].get_comp();
    endfunction
    function void s2(string nm, int x);
      as29[nm].get_comp1(x);
    endfunction
    function void s3(string nm);                  // plain handle (control)
      h29.get_comp();
    endfunction
    task s4(string nm);
      as29[nm].get_comp();
    endtask

    // --- inside a foreach, exactly as uvm writes it -------------------------
    function void f1(ref lst29 lst);
      foreach (as29[nm]) begin
        lst[nm] = as29[nm].get_comp();
      end
    endfunction

    // OUT-OF-BODY twin
    extern function void o1(ref lst29 lst, string nm);
  endclass

  function void dc29::o1(ref lst29 lst, string nm);
    lst[nm] = as29[nm].get_comp();
  endfunction

  // an explicit specialization, so the ELAB view carries a second copy
  class use29;
    dc29 #(rich29) u;
  endclass

endpackage
