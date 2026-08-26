// r10uvm160 grid, arm A — WHAT MAKES THE OPERAND BAD.
// One concatenation shape ({"[", <bad>, "]"}), one home (a generic class's
// DEFAULT specialization, where slang's diagnostics are suppressed and the
// badness is SILENT), and one axis: the kind of the sub-expression slang
// refuses to bind.  Every cell that our own binary answers rc!=0 on was
// REWRITTEN — an arm the tool refuses measures nothing.
// MEASUREMENT ONLY.
package pa160;
  class basea160;
    function new(string name="x"); endfunction
    function string gn(); return "g"; endfunction
  endclass

  class holda160 #(type T=int, type U=basea160, type S=string) extends basea160;
    static string sa = "";
    string ps;
    U uh;

    // a1 METHOD CALL on an int-typed type-parameter local  (the corpus head)
    function void a1(); T t; sa = {"[", t.gt(), "]"};                  endfunction
    // a2 MEMBER SELECT on the same local
    function void a2(); T t; sa = {"[", t.fld, "]"};                   endfunction
    // a3 `::` SCOPED name on the type parameter itself      (the uvm_utils head)
    function void a3();      sa = {"[", T::tn, "]"};                   endfunction
    // a4 `::` SCOPED CALL on the type parameter
    function void a4();      sa = {"[", T::mk(), "]"};                 endfunction
    // a5 a METHOD CALL ON A LOCAL WHOSE TYPE PARAMETER DEFAULTS TO `string`
    //    (the same call written on a plain `string` is a REPORTED slang error
    //    — `unknown built-in method` — which makes the whole test
    //    SLANG_REJECT and is out of the campaign's scope by decision; this
    //    cell is the SILENT spelling of it)
    function void a5(); S s5; sa = {"[", s5.nosuch160(), "]"};         endfunction
    // a6 a BAD ARGUMENT inside a GOOD call
    function void a6(); T t; sa = {"[", uh.gn(t.gt()), "]"};           endfunction
    // a7 NESTED bad inside good inside bad
    function void a7(); T t; sa = {"[", uh.gn({"<", t.gt(), ">"}), "]"}; endfunction
    // a8 the bad operand is the WHOLE concat's only operand
    function void a8(); T t; sa = {t.gt()};                            endfunction
    // a9 an INDEX SELECT on the type-param local — slang BINDS this one
    //    (a bit-select of an int is legal), so it is a NEGATIVE control:
    //    golden and BOTH our binaries must agree, before and after.
    function void a9(); T t; sa = {"[", t[0], "]"};                    endfunction
    // a10 a call on a REAL class handle — the ACCEPTED twin of a1
    function void a10();     sa = {"[", uh.gn(), "]"};                 endfunction
  endclass
endpackage

module topa160;
  initial $display("hi");
endmodule
