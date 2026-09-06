// r10v165 ADVERSARIAL arm D — § droppedIdxRecvCall26's SUBSCRIPTED receiver,
// the SECOND site the patch gates.  Depths 0..3, three container kinds (fixed
// array, queue, associative array), a CONSTANT index and a VARIABLE index, an
// else arm, a case item and a foreach body, plus the EXPRESSION-position twin
// (which must NOT change: its bind was already false).
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.

package vpk_d;

   class Bins #( type Tsink = int );
      Tsink      m_fix[4];
      Tsink      m_que[$];
      Tsink      m_map[string];
      static bit flap;
      int        m_dial;
      string     m_keys[$];

      function void depths(string wick, int cog);
         m_fix[cog].stow(wick);                   // d_fix0  d0 var index
         m_fix[2].stow(wick);                     // d_fixc0 d0 const index
         m_que[cog].stow(wick);                   // d_que0  d0
         m_map["k"].stow(wick);                   // d_map0  d0
         if (flap) begin
            m_fix[cog].stow(wick);                // d_fix1  d1
            m_fix[2].stow(wick);                  // d_fixc1 d1
            m_que[cog].stow(wick);                // d_que1  d1
            m_map["k"].stow(wick);                // d_map1  d1
            if (m_dial == 1) begin
               m_fix[cog].stow(wick);             // d_fix2  d2
               if (m_dial == 2) begin
                  m_fix[cog].stow(wick);          // d_fix3  d3
               end
            end
         end
      endfunction

      function void carriers(string wick, int cog);
         if (flap) m_fix[cog].stow(wick);         // e_if    d1
         else      m_fix[cog].stow(wick);         // e_else  d1
         case (cog)
           1: m_que[cog].stow(wick);              // e_case  d1
           default: m_que[cog].stow(wick);        // e_cdef  d1
         endcase
         foreach (m_keys[q])
            m_map[m_keys[q]].stow(wick);          // e_feach d1 (compound index)
         while (m_dial == 3)
            m_fix[cog].stow(wick);                // e_while d1
      endfunction

      // EXPRESSION position — § 26's other arm, bind already false
      function int exprs(string wick, int cog);
         int acc;
         acc = m_fix[cog].stow(wick);             // x_rhs0  d0
         if (m_fix[cog].stow(wick)) begin         // x_cond0 d0
            acc = 1;
         end
         if (flap) begin
            acc = m_fix[cog].stow(wick);          // x_rhs1  d1
            return m_que[cog].stow(wick);         // x_ret1  d1
         end
         return acc;
      endfunction

      // a plain (non-subscripted) receiver in the SAME method, for the pair
      Tsink m_plain;
      function void plain(string wick);
         m_plain.stow(wick);                      // p_pl0  d0
         if (flap) begin
            m_plain.stow(wick);                   // p_pl1  d1
         end
      endfunction
   endclass
endpackage

// NOTE — `Bins` is deliberately NOT instantiated.  An explicit specialization
// (`Bins #(int) b1;`) makes slang elaborate the body and REPORT the type
// errors, which rejects the whole file (rc=3): the dropped-call path exists
// only for the un-instantiated generic body, which is the corpus's own shape.

