// r10uvm58 VERIFIER arm w2 — THE LOCAL-DECLARATION PRODUCT CELLS a8 SKIPPED.
// a8 covers a plain subroutine local, a named-begin local and a LOOP-BODY
// local; it does NOT cover the LOOP VARIABLE ITSELF being of type T
// (StmtEmit.cpp:2157 is a distinct entry into the gated factory and is only
// reached when the loop variable is neither integral nor logic), nor a
// STATIC-lifetime local, nor a TASK local, nor a local declared through a
// TYPEDEF ALIAS to the type parameter (which the gate deliberately does not
// see, because a typedef's syntax kind is TypedefDeclaration, not
// TypeAssignment).  The alias cell is the UNDER-fire probe.
package p58w2;
   class c_w2 #(type T = int);
      T m_prop;
      function bit f_stat();
         static T stat_lv;             // STATIC-lifetime local of T
         stat_lv = m_prop;
         return 1;
      endfunction
      function bit f_loopvar();
         T sum;
         for (T i = 0; i < 2; i++)     // the LOOP VARIABLE is of type T
            sum = i;
         return 1;
      endfunction
      task t_local();                  // a TASK local, not a function local
         T tv;
         tv = m_prop;
      endtask
      function bit f_alias();
         typedef T alias_w2_t;         // TYPEDEF ALIAS to the type parameter
         alias_w2_t av;
         av = m_prop;
         return 1;
      endfunction
   endclass

   class c_w2s #(type T = string);      // the same, bound to a NON-integral
      T m_prop;
      T m_arr [3];
      function bit f_foreach();
         T last;
         foreach (m_arr[j])
            last = m_arr[j];
         return 1;
      endfunction
   endclass
endpackage

module w2_top58;
   initial begin end
endmodule
