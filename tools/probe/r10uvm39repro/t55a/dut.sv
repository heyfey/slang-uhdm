// t55a — pass 39, the `method_func_call`-under-`hier_path` ARGUMENT position,
// all cells on ONE golden.
//
// The corpus measurement (r10uvm39h over the UVM-4, 4761 rows in this exact
// position) says golden picks one of three targets for a reference that is an
// ARGUMENT of a method call written as `recv.m(args)` in EXPRESSION position:
//
//   base BOUND, path length 2, base not an array   -> the BASE's own object
//                                                     (266 rows; 4 exceptions,
//                                                      all `assoc.exists(k)`)
//   otherwise                                      -> the argument's own
//                                                     declaration, or nothing
//
// i.e. `factory.create_component(requested_type_name, get_full_name(), name,
// this)` inside an adpcm_pkg CLONE binds `requested_type_name`, `name` AND
// `this` to `class_var:factory` — the receiver — not to their own io_decls.
//
// This file asks the same question of a purpose-built golden and carries the
// negatives and the CORPUS-RISK cell (a class-method call from a MODULE body,
// where the base binds through ordinary module binding rather than through
// § pkgCloneHierBind9) in the same file, because the fix has to be gated so it
// cannot reach any of them.
//
// Read with tools/probe/r10uvm39h.cpp (every reference that is an argument of a
// method_func_call inside a hier_path, with the BASE element's own actual and a
// pointer-identity SAME flag) and cross-checked with r10uvm28g.

package home55;

   class inner55;
      int val;
      function int take55(int a, string b);
         return a;
      endfunction
      function int takeone55(int a);
         return a;
      endfunction
   endclass

   class mid55;
      inner55 deep;
      function int take55(int a, string b);
         return a;
      endfunction
   endclass

   class c55;
      inner55 prop;          // CLASS PROPERTY receiver
      mid55 midp;            // for the DEEP (nelem=3) cell
      inner55 parr[4];       // for the INDEXED-base cell
      int assoc[string];     // for the assoc-array built-in cell
      int acc;

      // CELL A — receiver is a FORMAL (io_decl), two reference arguments.
      function int viaFormal55(inner55 recv, int f, string s);
         return recv.take55(f, s);
      endfunction

      // CELL B — receiver is a CLASS PROPERTY (class_var).
      function int viaProp55(int f2, string s2);
         return prop.take55(f2, s2);
      endfunction

      // CELL C — receiver is a BODY LOCAL.
      function int viaLocal55(int f3, string s3);
         inner55 loc;
         loc = new();
         return loc.take55(f3, s3);
      endfunction

      // CELL D — DEEP receiver (`midp.deep.take55`, path length 3).
      function int viaDeep55(int f4, string s4);
         return midp.deep.take55(f4, s4);
      endfunction

      // CELL E — an ASSOCIATIVE-ARRAY BUILT-IN method with a bound base: the
      // measured exception (`visited.exists(succ)` stays SELF in golden).
      function int viaAssoc55(string k5);
         if (assoc.exists(k5))
            return 1;
         return 0;
      endfunction

      // CELL F — INDEXED receiver (`parr[i].takeone55(f6)`): the base element
      // is a bit_select, and the corpus says the argument stays SELF.
      function int viaIndex55(int i6, int f6);
         return parr[i6].takeone55(f6);
      endfunction

      // CELL G — the same call in STATEMENT position (no hier_path at all:
      // Surelog emits a flat method_func_call with the receiver as vpiPrefix).
      function void viaStmt55(inner55 recv7, int f7, string s7);
         acc = recv7.take55(f7, s7);
      endfunction

      // CELL H — the argument is a CLASS PROPERTY / `this` rather than a
      // formal: the corpus's `map.get_reg_map_info(this)` row says `this` also
      // takes the base's object.
      function int viaThis55(inner55 recv8);
         return recv8.takeone55(acc) + recv8.take55(prop.val, "x");
      endfunction
   endclass

   function automatic int free55(inner55 recv9, int f9, string s9);
      return recv9.take55(f9, s9);
   endfunction

endpackage

// The IMPORTER: its DEF and ELAB listings hold CLONES of every home55
// subroutine, and § pkgCloneHierBind9 binds a clone hier_path's base.  That is
// the view the 266 corpus rows live in.
package imp55;
   import home55::*;
   function automatic int g55(int m);
      c55 o;
      inner55 r;
      o = new();
      r = new();
      return o.viaFormal55(r, m, "s") + free55(r, m, "t");
   endfunction
endpackage

// THE CORPUS-RISK CELL — a class-method call in EXPRESSION position from a
// MODULE body, where the receiver binds through ordinary module binding.  If
// golden leaves the argument SELF here, the fix must not reach a module body.
module mm55;
   import home55::*;
   inner55 mh;
   int mf;
   string ms;
   int mq;
   initial begin
      mh = new();
      mf = 3;
      ms = "z";
      mq = mh.take55(mf, ms);
   end
endmodule
