// r10sd1 arm a1 — UVM-FREE FACTORY-REGISTRY GRID.
//
// The target is SeqDriver's `type_id` cluster: a class-scope typedef of a
// PARAMETERIZED class, written with an explicit `#(...)` argument list, whose
// class_typespec golden decorates with vpiParameter + vpiParamAssign (the
// SPECIALIZATION) while ours emits neither.  The grid varies the properties the
// brief names AND the two that Surelog's own code (`compileDatastructureTypespec`,
// CompileType.cpp:904-1000) says decide it:
//
//   * whether the written target carries `#(...)` at all;
//   * whether an ordered argument names a CONCRETE type or a TYPE PARAMETER of
//     the enclosing generic class (Surelog's `datatype_cast<const Parameter*>`
//     arm returns nullptr -- "Prevent circular definition");
//   * ordered vs NAMED argument spelling (only paOrdered_parameter_assignment
//     is walked);
//   * a VALUE argument next to a type one (the string `S` of uvm's registry);
//   * a SECOND typedef of the same target (the clone half of the group law);
//   * where the typedef lives: class scope / package scope / module scope;
//   * where the specialization is REFERENCED from: module / package / class
//     method.
//
// No UVM, no macros: every cell is one line of ordinary SystemVerilog.
package p1;

  class base1;
  endclass

  // ---- the "registry": a package class parameterized by a type + a string.
  class reg1 #(type T = base1, string TN = "<unknown>");
    typedef reg1 #(T, TN) self1;          // cell m06: args are OWN type params
    static function T make1();
      return null;
    endfunction
  endclass

  class item1 extends base1;
  endclass

  class item2 extends base1;
  endclass

  // ---- CLASS-SCOPE typedefs of the registry, the SeqDriver shape.
  class user1 extends base1;
    typedef reg1 #(item1, "item1") tid1;  // cell m01: ordered, concrete + value
    static function tid1 gt1();            // cell m02: the RETURN-TYPE ref slot
      return null;
    endfunction
  endclass

  class user2 extends base1;
    typedef reg1 #(item2, "item2") tid2;  // cell m03: SECOND typedef, same
                                          //           generic -> the CLONE half
  endclass

  class user3 extends base1;
    typedef reg1 #(.T(item1), .TN("item1")) tid3;  // cell m04: NAMED args
  endclass

  class user4 extends base1;
    typedef reg1 tid4;                    // cell m05: NO `#(...)` at all
  endclass

  class gen1 #(type U = base1);
    typedef reg1 #(U, "u") tid5;          // cell m07: arg is THIS class's own
                                          //           type parameter
  endclass

  class user5 extends base1;
    typedef reg1 #(item1) tid6;           // cell m08: ordered, ONE arg, the
                                          //           value formal defaulted
  endclass

  // ---- PACKAGE-SCOPE typedef of the same shape.
  typedef reg1 #(item1, "item1") ptid1;    // cell m09

  // ---- referenced from a PACKAGE-level variable.
  ptid1 pvar1;                             // cell m10

  // ---- referenced from a class METHOD body.
  class user6 extends base1;
    function void use1();
      reg1 #(item2, "item2") lv1;          // cell m11
      lv1 = null;
    endfunction
  endclass

endpackage

module top1;
  import p1::*;

  // ---- MODULE-SCOPE typedef of the same shape.
  typedef reg1 #(item2, "item2") mtid1;    // cell m12

  // ---- referenced from a MODULE variable, via the package typedef.
  ptid1 mv1;                               // cell m13
  mtid1 mv2;                               // cell m14
  reg1 #(item1, "item1") mv3;              // cell m15: written inline

  initial begin
    mv1 = null;
    mv2 = null;
    mv3 = null;
  end
endmodule
