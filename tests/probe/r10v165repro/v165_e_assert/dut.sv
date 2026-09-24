// r10v165 ADVERSARIAL arm E — the carriers that are NOT in `CtrlBody28`'s ten
// raise sites, and therefore keep the bind under the patched gate.  If golden
// leaves any of them BARE the gate is INCOMPLETE; if golden binds them the gate
// is right to leave them alone.  Includes the § assertCondIsAClassMethodWindow161
// neighbourhood (an immediate assertion's PASS and FAIL action blocks), a
// `wait` statement, an event control in a task, all three fork joins, and a
// `disable fork`.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.

package vpk_e;

   class Guard #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      event      m_ev;

      function void asserts(string wick);
         m_sink.stow(wick);                       // g_top   d0 (control)
         assert (m_dial == 1)
            m_sink.stow(wick);                    // g_apass d? assert PASS body
         else
            m_sink.stow(wick);                    // g_afail d? assert FAIL body
         assert (m_dial == 2) begin
            m_sink.stow(wick);                    // g_apassb d? + begin
         end
         assume (m_dial == 3)
            m_sink.stow(wick);                    // g_assume d?
         if (flap) begin
            assert (m_dial == 4)
               m_sink.stow(wick);                 // g_a_in_if d1 + assert
         end
      endfunction

      task waits(string wick);
         m_sink.stow(wick);                       // g_wtop  d0
         wait (m_dial == 1);
         m_sink.stow(wick);                       // g_afterwait d0
         @(m_ev);
         m_sink.stow(wick);                       // g_afterev d0
         fork
            m_sink.stow(wick);                    // g_forkjoin  d?
         join
         fork
            m_sink.stow(wick);                    // g_forkany   d?
         join_any
         fork
            m_sink.stow(wick);                    // g_forknone  d?
         join_none
         fork
            begin
               m_sink.stow(wick);                 // g_forkbeg   d?
            end
         join_none
      endtask
   endclass
endpackage
