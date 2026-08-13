// r10uvm66 arm a2 — THE SLOT / KIND DISCRIMINATOR ARM.
//
// a1 fixed the TERM (the initializer is a WRITTEN `new`) on the subroutine-body
// slot.  a2 asks the two questions a1 could not:
//
//   (1) WHICH SLOTS.  Our emitter builds a declaration-initializer assignment at
//       THREE places: the subroutine-BODY statement list (StmtEmit ~3092, the
//       head's site), the WRITTEN-block path (emitDeclStmt9 ~1330, which ALREADY
//       carries a NewClass-only clause) and the CONSTRUCTOR path (emitCtorBody27
//       EK_BID ~812).  a1's constructor cell was MASKED by
//       § constructorBodyElementShift27 (a port-less constructor loses its first
//       element whatever it is), so n01 gives the constructor a PORT LIST.
//   (2) WHICH `new`.  The existing block-path clause tests `NewClass` only.
//       n02/n03/n10 are the dynamic-array `new[...]` cells that decide whether
//       that clause is one term short.
//
// Plus every slot a statement list can be: fork, for/while body, case item, a
// module `initial`/`always`, a tf-item body, and the all-elements-dropped list.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package a2p;

   class a2base;
      int m_lhs, m_rhs;
      function new(string name="unnamed");
      endfunction : new
      function void set(int lhs, int rhs);
         m_lhs = lhs;
         m_rhs = rhs;
      endfunction : set
   endclass

   class a2c extends a2base;
      int fld;
      function new(string name="unnamed-a2c");
         super.new(name);
      endfunction : new
   endclass

   // n01 — A CONSTRUCTOR **WITH A PORT LIST**, so § constructorBodyElementShift27
   //       does not eat the first element and the declaration is really measured.
   class a2ctorp;
      int fld;
      function new(int seed);
         a2c ce = new();
         ce.set(seed, 2);
         fld = seed;
      endfunction : new
   endclass

   // n01b — the same constructor with an INT decl-init, as the control that says
   //        the constructor slot keeps ordinary declaration assignments.
   class a2ctorq;
      int fld;
      function new(int seed);
         int x = 5;
         fld = seed + x;
      endfunction : new
   endclass

   class a2slots;
      int fld;
      int src[];

      // n02 — a WRITTEN begin inside a subroutine, dynamic-array `new[]`.
      function void n02_blkdyn();
         fld = 0;
         begin
            int d[] = new[3];
            fld = 1;
         end
      endfunction : n02_blkdyn

      // n02b — a WRITTEN begin inside a subroutine, class-handle `new()`
      //        (the slot the existing clause already covers).
      function void n02b_blkcls();
         fld = 0;
         begin
            a2c ce = new();
            ce.set(1, 2);
         end
      endfunction : n02b_blkcls

      // n05 — a FORK's statement list.
      task n05_fork(int a);
         fork
            begin
               a2c ce = new();
               ce.set(a, 2);
            end
         join
      endtask : n05_fork

      // n06 — a FOR-loop body block.
      function void n06_forbody();
         for (int i = 0; i < 2; i++) begin
            a2c ce = new();
            ce.set(i, 2);
         end
      endfunction : n06_forbody

      // n22 — a WHILE-loop body block.
      function void n22_whilebody();
         int k = 0;
         while (k < 2) begin
            a2c ce = new();
            ce.set(k, 2);
            k++;
         end
      endfunction : n22_whilebody

      // n23 — a CASE-item block.
      function void n23_caseitem(int sel);
         case (sel)
            0: begin
                  a2c ce = new();
                  ce.set(0, 2);
               end
            default: fld = 1;
         endcase
      endfunction : n23_caseitem

      // n07 — a body whose EVERY element is a `new`-initialized declaration:
      //       if the drop is unconditional the surviving list is EMPTY.
      function void n07_alldropped();
         a2c p = new();
         a2c q = new();
      endfunction : n07_alldropped

      // n08 — a body with a `new` decl and an INT decl and no other statement.
      function void n08_mixeddecls();
         int x = 5;
         a2c q = new();
      endfunction : n08_mixeddecls

      // n09 — `new` written with NO PARENTHESES.
      function void n09_noparens();
         a2c ce = new;
         ce.set(1, 2);
      endfunction : n09_noparens

      // n10 — the dynamic-array COPY form `new[n](src)`.
      function void n10_dyncopy();
         int d[] = new[3](src);
         fld = 1;
      endfunction : n10_dyncopy

      // n10b — dynamic array `new[n]` in a plain subroutine body (the a1 m08
      //        cell repeated here so a2 stands alone).
      function void n10b_dynplain();
         int d[] = new[3];
         fld = 1;
      endfunction : n10b_dynplain

      // n11 — declared here, DEFINED OUT OF BODY below.
      extern function void n11_oob();

      // n27 — a `new` decl followed by a NON-`new` decl, to fix the order of
      //       the surviving assignments.
      function void n27_order();
         a2c p = new();
         int x = 5;
         fld = x;
      endfunction : n27_order

   endclass

   function void a2slots::n11_oob();
      a2c ce = new();
      ce.set(1, 2);
   endfunction : n11_oob

   // n14 — a PARAMETERIZED class handle.
   class a2par #(int W = 4);
      int fld;
      function void set2(int a);
         fld = a + W;
      endfunction : set2
   endclass

   class a2parhost;
      int fld;
      function void n14_par();
         a2par #(8) h = new();
         h.set2(1);
      endfunction : n14_par
   endclass

   // n15 — a TYPEDEF'd class handle.
   typedef a2c a2c_t;
   class a2tdhost;
      int fld;
      function void n15_td();
         a2c_t h = new();
         h.set(1, 2);
      endfunction : n15_td
   endclass

   // n16 — a class PROPERTY with a `new()` initializer (not a statement list at
   //       all: the control that says this law is about STATEMENT LISTS).
   class a2prop;
      a2c h = new();
      int fld;
      function void touch();
         fld = 1;
      endfunction : touch
   endclass

endpackage

// n19 — a $unit-scope function.
function automatic void n19_unitfn();
   a2p::a2c ce = new();
   ce.set(1, 2);
endfunction : n19_unitfn

module a2mod;
   import a2p::*;
   int fld;
   int src[];

   // n17 — a module-scope variable with a `new()` initializer (control).
   a2c mh = new();

   // n03 — an INITIAL block, dynamic-array `new[]`.
   initial begin
      int d[] = new[3];
      fld = 1;
   end

   // n04 — an INITIAL block, class-handle `new()` (the site the existing
   //       block-path clause was measured on).
   initial begin
      a2c ce = new();
      ce.set(1, 2);
   end

   // n20 — an ALWAYS block.
   always @(fld) begin
      a2c ce = new();
      ce.set(2, 3);
   end

   // n24 — a body whose declarations are TF-ITEM declarations: a NON-ANSI body
   //        io makes slang's block items tf_item_declarations, which is the one
   //        body shape whose locals do NOT re-parent at the wrapper begin
   //        (tfBodyTfItems9).  Only a module/interface subroutine can be written
   //        this way; a class method may not.
   task n24_tfitems;
      input int a;
      a2c ce = new();
      ce.set(a, 2);
   endtask : n24_tfitems

   // n21 — a subroutine body whose SOLE element is a written begin holding
   //       only a `new`-initialized declaration.
   function automatic void n21_soleblk();
      begin
         a2c ce = new();
      end
   endfunction : n21_soleblk
endmodule

interface a2if;
   int fld;
   // n12 — an INTERFACE-scope function.
   function automatic void n12_iffn();
      a2p::a2c ce = new();
      ce.set(1, 2);
   endfunction : n12_iffn
endinterface

program a2prog;
   int fld;
   // n13 — a PROGRAM-scope function.
   function automatic void n13_progfn();
      a2p::a2c ce = new();
      ce.set(1, 2);
   endfunction : n13_progfn
endprogram
