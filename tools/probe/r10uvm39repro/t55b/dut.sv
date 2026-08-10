// t55b — pass 39 cell matrix, ALL SHAPES INSIDE A CLONE BODY.
//
// t55a proved the law exists (`imp55::free55`'s clone binds both arguments of
// `recv9.take55(f9, s9)` to `io_decl:recv9`, the receiver) and carried the two
// negatives that matter for the fix's gate — the home package's own listing and
// a MODULE body both leave the hier_path BASE bare, so a gate that requires a
// BOUND base cannot reach either.  What t55a could NOT answer is what the other
// shapes do IN THE CLONE VIEW: its deep / indexed / assoc / statement cells were
// class methods written INSIDE the class, which an importer does not clone at
// all, so every one of them was measured in the home listing where the base is
// bare and the answer is vacuous.
//
// So every cell here is a home56 FREE FUNCTION (cloned into both of imp56's
// listings) or an OUT-OF-BODY class method (ditto — that is exactly the UVM
// shape: `function void uvm_component::foo(...)` written outside the class), and
// each one puts the receiver in a position where § pkgCloneHierBind9 binds it.
//
//   read with tools/probe/r10uvm39h.cpp
package home56;

   class inner56;
      int val;
      function int take56(int a, string b);
         return a;
      endfunction
      function int one56(int a);
         return a;
      endfunction
      function void do56(int a, string b);
      endfunction
   endclass

   class mid56;
      inner56 deep;
      function int take56(int a, string b);
         return a;
      endfunction
   endclass

   int pkgvar56;

   // CELL A — receiver is a FORMAL, two plain reference arguments.
   function automatic int fFormal56(inner56 recv, int f, string s);
      return recv.take56(f, s);
   endfunction

   // CELL B — receiver is a BODY LOCAL.
   function automatic int fLocal56(int f2, string s2);
      inner56 loc;
      loc = new();
      return loc.take56(f2, s2);
   endfunction

   // CELL C — DEEP receiver, path length 3.
   function automatic int fDeep56(mid56 m3, int f3, string s3);
      return m3.deep.take56(f3, s3);
   endfunction

   // CELL D — INDEXED receiver: the base element is a bit_select.
   function automatic int fIndex56(int i4, int f4);
      inner56 parr[4];
      return parr[i4].one56(f4);
   endfunction

   // CELL E — ASSOCIATIVE-ARRAY BUILT-IN method on a bound base: the measured
   // exception in the corpus (`visited.exists(succ)` keeps SELF).
   function automatic int fAssoc56(string k5);
      int loc5[string];
      if (loc5.exists(k5))
         return 1;
      return 0;
   endfunction

   // CELL F — STATEMENT position (Surelog builds a flat method_func_call with
   // the receiver as vpiPrefix, no hier_path at all).
   function automatic void fStmt56(inner56 recv6, int f6, string s6);
      recv6.do56(f6, s6);
   endfunction

   // CELL G — the argument is a PACKAGE variable, not one of the body's own
   // names (the corpus's `map.get_reg_map_info(this)` shape).
   function automatic int fOther56(inner56 recv7, int f7);
      return recv7.one56(pkgvar56) + recv7.one56(f7);
   endfunction

   // CELL H — the reference is NESTED INSIDE an argument EXPRESSION rather than
   // being the argument itself.  This decides whether the fix re-points the
   // direct arguments only or the whole argument subtree.
   function automatic int fNested56(inner56 recv8, int f8, string s8);
      return recv8.take56(f8 + 1, s8);
   endfunction

   // CELL I — the same call in the RHS of an assignment rather than a return,
   // to show the enclosing statement kind is not the distinguisher.
   function automatic int fAssign56(inner56 recv9, int f9, string s9);
      int r9;
      r9 = recv9.take56(f9, s9);
      return r9;
   endfunction

   // CELL J — an OUT-OF-BODY CLASS METHOD (the UVM shape), formal receiver.
   class holder56;
      int acc;
      extern function int viaFormal56(inner56 recvA, int fA, string sA);
      extern function int viaProp56(int fB, string sB);
      inner56 prop;
   endclass

   function int holder56::viaFormal56(inner56 recvA, int fA, string sA);
      return recvA.take56(fA, sA);
   endfunction

   // CELL K — out-of-body method whose receiver is a CLASS PROPERTY, and whose
   // argument is a class property too.
   function int holder56::viaProp56(int fB, string sB);
      return prop.take56(fB, sB) + prop.one56(acc);
   endfunction

endpackage

package imp56;
   import home56::*;
   function automatic int g56(int m);
      inner56 r;
      holder56 h;
      r = new();
      h = new();
      return fFormal56(r, m, "s") + h.viaFormal56(r, m, "t");
   endfunction
endpackage

module mm56;
   import home56::*;
   int q;
   initial q = fFormal56(null, 1, "x");
endmodule
