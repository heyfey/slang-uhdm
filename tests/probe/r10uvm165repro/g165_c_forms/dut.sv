// r10uvm165 arm C — the ARGUMENT FORMS, the $unit home, the EXPRESSION-position
// twin, and the corpus statement written out in miniature.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.

// ---- $unit scope -----------------------------------------------------------
class UnitCache165 #( type Timp = int );
   Timp m_imp;
   static bit gate;
   function void run(string tag_nm);
      int perch = 2;
      m_imp.absent(tag_nm);                  // u01 d0  $unit class, formal
      m_imp.absent(perch);                   // u02 d0  $unit class, body local
      if (gate) begin
         m_imp.absent(tag_nm);               // u03 d1
      end
   endfunction
endclass

package fpk165;
   int pkg_dial165;

   typedef struct { int lo; int hi; } pair165_t;

   class Nook165;
      int  slat;
      function void keep(string nm); endfunction
   endclass

   class Forms165 #( type Timp = int, string Tname = "<none>" );
      Timp      m_imp;
      static bit gate;
      int       prop_dial;

      function void run(string tag_nm, int cog);
         pair165_t span;
         Nook165   nook = null;
         int       perch = 1;

         // ---- ARGUMENT FORMS, all at d0 (must keep binding) -------------
         m_imp.absent(tag_nm);               // f01 bare FORMAL
         m_imp.absent(cog);                  // f02 second FORMAL
         m_imp.absent(perch);                // f03 body LOCAL
         m_imp.absent(tag_nm, cog);          // f04 TWO formals in one call
         m_imp.absent(prop_dial);            // f05 class PROPERTY
         m_imp.absent(pkg_dial165);          // f06 PACKAGE variable
         m_imp.absent(span.lo);              // f07 DOTTED PAIR (never bound)
         m_imp.absent(nook.slat);            // f08 DOTTED PAIR through a handle
         m_imp.absent(Tname);                // f09 the class's own PARAMETER

         // ---- the same forms at d1 (must all go bare) -------------------
         if (gate) begin
            m_imp.absent(tag_nm);            // f11
            m_imp.absent(cog);               // f12
            m_imp.absent(perch);             // f13
            m_imp.absent(tag_nm, cog);       // f14
            m_imp.absent(prop_dial);         // f15
            m_imp.absent(pkg_dial165);       // f16
            m_imp.absent(span.lo);           // f17
         end

         // ---- EXPRESSION position: the SAME dropped call as a value -----
         // § droppedCall14's expression arm already binds nothing (`bind =
         // false`); these are the cells that must not change either way.
         perch = m_imp.absent(tag_nm);       // f21 d0 assignment RHS
         if (m_imp.absent(tag_nm)) begin     // f22 d0 if CONDITION
            perch = 3;
         end
         if (gate) begin
            perch = m_imp.absent(tag_nm);    // f23 d1 assignment RHS
         end
      endfunction

      // ---- the corpus statement, in miniature ---------------------------
      // uvm_registry.svh:594-603 — a static method whose formal is passed to a
      // BUILT-IN method at the top level and to a DROPPED call two control
      // bodies down.
      local static string m__labels[$];
      static function void set_label(string label_nm);
         m__labels.push_back(label_nm);      // f31 d0  builtin, class property
         m__labels.sort();
         if (gate) begin
            Timp forge;
            int  slot = 3;
            if (slot == 1) begin
               forge.absent(label_nm, slot); // f32 d2  THE CORPUS CELL
            end
         end
      endfunction

      // a dropped call inside a RETURN — § droppedCall14's return arm
      function int fetch(string tag_nm);
         if (gate) begin
            return m_imp.absent(tag_nm);     // f41 d1 return operand
         end
         return m_imp.absent(tag_nm);        // f42 d0 return operand
      endfunction
   endclass
endpackage
