// r10v165 ADVERSARIAL arm C — the HOMES and the MUST-STAY controls.
//   * an OUT-OF-BODY definition at depths 0,1,2,3 (the `!curSubOob9` conjunct:
//     golden binds ALL of them; a depth-only gate would strip 1..3)
//   * a $unit-scope generic class at depths 0..3
//   * a MODULE-homed generic class (R-modcls) at depths 0..2
//   * a MODULE-scope function whose call arguments must stay golden-bound at
//     depth > 0 (the ordinary path's control; the patch must not reach it)
//   * a static method, a virtual method, a constructor, a task
//   * receiver faces: `this.`, a chained `a.b.c(x)`, a static path `C::m(x)`,
//     a call on the RETURN of another call
//   * THREE instances of the same specialization plus a SECOND specialization
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.

// ---------------- $unit scope ------------------------------------------------
class UnitHome #( type Tsink = int );
   Tsink      m_sink;
   static bit flap;
   int        m_dial;
   function void deep(string wick);
      m_sink.stow(wick);                          // U0 d0
      if (flap) begin
         m_sink.stow(wick);                       // U1 d1
         if (m_dial == 1) begin
            m_sink.stow(wick);                    // U2 d2
            while (m_dial == 2) begin
               m_sink.stow(wick);                 // U3 d3
            end
         end
      end
   endfunction
endclass

package vpk_c;

   class Leaf;
      int  cog;
      Leaf nest;
      function void keep(string nm); endfunction
      static function void brand(string nm); endfunction
   endclass

   // ---------------- out-of-body, four depths --------------------------------
   class Oob #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      extern function void deep(string wick);
      extern static function void sdeep(string wick);
   endclass

   function void Oob::deep(string wick);
      m_sink.stow(wick);                          // O0 d0
      if (flap) begin
         m_sink.stow(wick);                       // O1 d1
         if (m_dial == 1) begin
            m_sink.stow(wick);                    // O2 d2
            for (int q = 0; q < 2; q++) begin
               m_sink.stow(wick);                 // O3 d3
            end
         end
      end
   endfunction

   function void Oob::sdeep(string wick);
      Tsink loc_sink;
      if (flap) begin
         if (flap) begin
            loc_sink.stow(wick);                  // OS2 d2 static, out-of-body
         end
      end
   endfunction

   // ---------------- in-body, the four method flavours -----------------------
   class Flavours #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      Leaf       m_leaf;

      function new(string wick);
         m_sink.stow(wick);                       // F_ctor0 d0
         if (flap) begin
            m_sink.stow(wick);                    // F_ctor1 d1
         end
      endfunction

      static function void sfn(string wick);
         Tsink loc_sink;
         loc_sink.stow(wick);                     // F_stat0 d0
         if (flap) begin
            loc_sink.stow(wick);                  // F_stat1 d1
         end
      endfunction

      virtual function void vfn(string wick);
         m_sink.stow(wick);                       // F_virt0 d0
         if (flap) begin
            m_sink.stow(wick);                    // F_virt1 d1
         end
      endfunction

      task tfn(string wick);
         m_sink.stow(wick);                       // F_task0 d0
         if (flap) begin
            m_sink.stow(wick);                    // F_task1 d1
         end
      endtask

      // ---------------- receiver FACES ---------------------------------------
      function void faces(string wick);
         this.m_sink.stow(wick);                  // R_this0 d0
         m_leaf.nest.keep(wick);                  // R_chain0 d0 (a.b.c form)
         Leaf::brand(wick);                       // R_static0 d0
         if (flap) begin
            this.m_sink.stow(wick);               // R_this1 d1
            m_leaf.nest.keep(wick);               // R_chain1 d1
            Leaf::brand(wick);                    // R_static1 d1
         end
      endfunction
   endclass

   // ---------------- MODULE-scope function control ---------------------------
   // Not a class method at all: `curSubClassScope9` is false, so the patch must
   // leave every one of these bound exactly as golden has them.
endpackage

module vmod_c;
   import vpk_c::*;

   // a MODULE-homed generic class (R-modcls)
   class ModHome #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      function void deep(string wick);
         m_sink.stow(wick);                       // M0 d0
         if (flap) begin
            m_sink.stow(wick);                    // M1 d1
            if (m_dial == 1) begin
               m_sink.stow(wick);                 // M2 d2
            end
         end
      endfunction
   endclass

   int  mvec[4];
   int  mtot;

   // a MODULE function: ordinary path, arguments must stay bound at any depth
   function int mfn(int knob, int cogs);
      int acc;
      acc = mhelp(knob);                          // MF0 d0
      if (knob == 1) begin
         acc = mhelp(cogs);                       // MF1 d1
         if (cogs == 2) begin
            acc = mhelp(knob);                    // MF2 d2
         end
      end
      return acc;
   endfunction

   function int mhelp(int v);
      return v + 1;
   endfunction

   // NOTE — the generic classes above are deliberately NOT instantiated with an
   // explicit specialization.  Declaring `Flavours #(int) f1;` forces slang to
   // elaborate that specialization and REPORT the type errors, which rejects
   // the whole file (rc=3) and produces no database at all: the dropped-call
   // path exists only for the un-instantiated body, where slang suppresses the
   // diagnostics.  That is the corpus's own shape (`uvm_registry_common`'s
   // DEFAULT specialization) and it is why this arm holds no class variables.
   initial begin
      mtot = mfn(1, 2);
   end
endmodule
