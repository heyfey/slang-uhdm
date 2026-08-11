// r10uvm55repro arm a1 — the `obj = new()` RHS inside a GENERIC class whose
// handle variable's declared type is a TYPE PARAMETER.  This is the shape of
// uvm-1.2 `base/uvm_registry.svh:207` (`if (name=="") obj = new();` inside
// `uvm_object_registry #(type T=uvm_object, string Tname="<unknown>")`), which is
// SimpleUVM's and Scoreboard's cmp head:
//     LHS golden: method_func_call (new) |vpiParent assignment @207:19-207:30
//     RHS: <null>
// and which our side emits as an `assignment` with NO Rhs at all (measured with
// r10uvm55repro/asgat.cpp on the CONTROL database).
//
// The cells separate the ABSTRACT-DEFAULT type parameter from every neighbouring
// candidate cause; C1/C2 REFUTED the first hypothesis ("the type is a parameter").
//   C1  tp_noarg   : `T obj; obj = new();` @44 — the corpus SHAPE but with a
//                    CONCRETE default for T, so it BINDS and both sides already
//                    agree: the control proving the distinguisher is the ABSTRACT
//                    default, NOT "the variable's type is a type parameter".
//   C2  tp_arg     : the same with an argument, `obj = new(name);`   @46
//   C3  cc_noarg   : concrete-class handle `h = new();`              @53 control
//   C4  cc_arg     : concrete-class handle `h = new("k");`           @58 control
//   C5  tp_decl    : `T obj = new();` declaration initialiser        @63 — we
//                    emit an extra assignment golden has none of (residue R6).
//   C7  ng_tp      : typedef-typed handle, NON-GENERIC class @73. There is no C6.
// A module instantiates one concrete specialization so the generic is elaborated.
`ifdef NOTHING
`endif

class base55;
    function new(string name = "");
    endfunction
endclass

class other55 extends base55;
    function new(string name = "");
        super.new(name);
    endfunction
endclass

// C1/C2/C5/C6: the generic class, type parameter T with a default.
class gen55 #(type T = base55, string Tname = "<unknown>");
    // C1 — the corpus shape, no argument, inside an if/else.
    virtual function base55 c1_tp_noarg(string name = "");
        T obj;
        if (name == "")
            obj = new();
        else
            obj = new(name);
        return obj;
    endfunction
    // C3/C4 — concrete-class controls in the SAME generic body, so "generic
    // class" alone cannot explain a difference between C1 and C3.
    virtual function base55 c3_cc_noarg();
        other55 h;
        h = new();
        return h;
    endfunction
    virtual function base55 c4_cc_arg();
        other55 h;
        h = new("k");
        return h;
    endfunction
    // C5 — the declaration-initialiser form of C1.
    virtual function base55 c5_tp_decl();
        T obj = new();
        return obj;
    endfunction
endclass

// C7 — a NON-generic class with a `type` localparam-typed handle.
class ng55;
    typedef base55 TT;
    virtual function base55 c7_ng_tp();
        TT obj;
        obj = new();
        return obj;
    endfunction
endclass

// C8 — the DEFAULT of the type parameter is an ABSTRACT (`virtual`) class, which
// is what uvm-1.2 actually has: `uvm_object_registry #(type T=uvm_object, ...)`
// and `uvm_component_registry #(type T=uvm_component, ...)`, and BOTH
// `uvm_object` and `uvm_component` are declared `virtual class`.  slang binds the
// generic's DEFAULT specialization, where `obj = new()` creates an instance of an
// abstract class and is therefore an ERROR — so the bound expression is invalid
// and our emitter had nothing to emit.  Surelog never type-checks it and emits
// the `new` call anyway.  C8 vs C1 is the whole distinguisher.
virtual class vbase55;
    function new(string name = "");
    endfunction
    pure virtual function void vf();
endclass

class gen8_55 #(type T = vbase55, string Tname = "<unknown>");
    virtual function vbase55 c8_abstract_default(string name = "");
        T obj;
        if (name == "")
            obj = new();
        else
            obj = new(name);
        return obj;
    endfunction
endclass

class conc8_55 extends vbase55;
    // An EXPLICIT constructor: a derived class with NO `new` of its own gets
    // slang's IMPLICIT 0-argument constructor, and `new(name)` on the
    // specialization then fails with "too many arguments for 'new'; expected 0"
    // — which is a property of THIS CELL's concrete class, not of the abstract
    // default, and it cost one arm run to separate the two.
    function new(string name = "");
        super.new(name);
    endfunction
    virtual function void vf();
    endfunction
endclass

// C9 — BARE `new`, no parentheses, on an abstract-class-typed target.  This is
// uvm-1.2 `comps/uvm_pair.svh:67` (`first = new;`) and
// `comps/uvm_random_stimulus.svh:101` (`t = new;`).
// C10 — the type parameter's default is NOT A CLASS AT ALL (`type T1 = int`),
// which is literally `uvm_built_in_pair #(type T1=int, T2=T1)`.  slang takes a
// DIFFERENT badExpr branch here (`!assignmentTarget->isClass()` ->
// diag::NewClassTarget) than for the abstract class
// (`classType->isAbstract` -> diag::NewVirtualClass), both in
// slang/source/ast/expressions/AssignmentExpressions.cpp `resolveNewClassTarget`,
// and both end in `badExpr(comp, nullptr)`.  Two branches, one law.
// C11 — an ASSOCIATIVE-ARRAY ELEMENT as the assignment target:
// `base/uvm_pool.svh:307` `pool[key] = new (key);`.
class gen9_55 #(type T1 = int, type T2 = vbase55);
    T1 c10_first;
    T2 c9_t;
    T2 c11_pool[string];
    function void c9_bare_new();
        c9_t = new;
    endfunction
    function void c10_nonclass_default();
        c10_first = new;
    endfunction
    function void c11_assoc_elem(string key);
        if (!c11_pool.exists(key))
            c11_pool[key] = new (key);
    endfunction
endclass

module top55;
    // Elaborate one concrete specialization of the generic.
    gen55 #(other55, "other55") g;
    ng55 n;
    gen8_55 #(conc8_55, "conc8_55") g8;
    initial begin
        g = new();
        n = new();
        g8 = new();
    end
endmodule
