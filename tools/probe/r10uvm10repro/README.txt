r10uvm10repro — the purpose-built golden PAIRS that decoded UVM pass 10.
Run each with tools/probe/r10uvm9run.sh (re-point W to your worktree) or the
equivalent: surelog -parse [-elabuhdm] -nobuiltin -nocache -sv -mt 0 -mp 0
vs slang-uhdm --nobuiltin [--elabuhdm].

t1  § timeRetVar10.  `time t1;` as a CLASS PROPERTY is a time_var on both
    sides; the identical `time l1;` inside a method and `function time
    get_t()` were logic_vars for us because makeReturnVar had no Time arm.
    The TYPESPEC was already time_typespec on both sides — only the variable
    object kind differed.  BYTE-IDENTICAL to golden after the fix, both views.

t2  § aliasClassRefVar10, first cut.  Class-scope typedefs to int / enum /
    struct / a package-scope int typedef ALL keep their ordinary var kind
    (int_var, enum_var, struct_var); only `typedef Inner inner_t` — an alias
    of a CLASS — turns the return and the local into ref_var.  Writing the
    class name `Inner` directly stays class_var.  So the discriminator is the
    TARGET being a class, not the typedef's scope.

t3  § aliasClassRefVar10, scope split.  Same alias as a class PROPERTY, a
    PACKAGE variable and a MODULE variable stays class_var; as a subroutine
    RETURN and a subroutine LOCAL it is ref_var; as a FORMAL it is an
    io_decl and unaffected.  Both a class-scope and a package-scope alias
    behave identically, so "scope of the typedef" is not the discriminator
    either — "scope of the DECLARATION" is.

t4  § aliasClassRefVar10, statement scope.  A module-level `initial` block
    local and an `always_comb` local through the alias are ref_var too, while
    the direct class name in the same block stays class_var — the rule is
    statement/subroutine scope, not "inside a class".

t5  § aliasClassRefVar10, the type-PARAMETER exception.  In `class G #(type
    T = Inner)`, `function T gf(); T l;` is class_var in BOTH views while the
    `typedef G#(T) this_type` beside it is ref_var.  slang models a
    `parameter type` as a TypeAliasType, so the rule needs typeParamOfAlias
    to tell them apart (without it we over-fired on 30 uvm returns —
    uvm_queue#(T)::get, uvm_pool#(VAL)::get, uvm_object_registry#(T)::create).

t6  § pureVirtRet10.  A `pure virtual function` prototype carries its Return
    variable (class_var / int_var / string_var by the ordinary return rules,
    anonymous class_typespec at the return-type token); a pure virtual TASK
    carries none.  RESIDUE, measured and NOT implemented: golden's
    pure-virtual prototype ALSO carries its IO_DECLS (`int a` -> io_decl with
    an int_typespec) and ours has none — that is the next first-fail on t6
    and the reason it is not byte-identical yet.
