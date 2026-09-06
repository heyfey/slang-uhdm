// r10v165 ADVERSARIAL arm B — the SYMBOL side the brief asked about:
//   * a formal whose NAME is re-declared as a local INSIDE the if's begin
//     (`currentSubSym->find` sees the FORMAL, so the pristine binary binds the
//     WRONG object; what does golden do?)
//   * a local declared in an UNNAMED statement block at the SAME control depth
//     (§ blkLocalSameCtrlDepthArgBinds57 / § blkLocalSameCtrlDepthWindowBinds64
//     — golden's one documented depth>0 BIND; can the dropped path reach it?)
//   * the argument as an EXPRESSION containing the formal, and as an INDEXED
//     use (both outside § droppedCall14's accepted shapes — must produce no
//     cell at all, and must not change)
//   * 1, 2 and 3 arguments in one call, mixed kinds
//   * a for-loop ITERATOR as the argument
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.

package vpk_b;

   int   depot_glob;

   class Shadow #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      int        m_vec[4];

      // ---- the SHADOW: the if-block redeclares the formal's name ----------
      function void shadow_fn(string wick, int knob);
         m_sink.stow(wick);                       // s_top   d0 the formal
         if (flap) begin
            string wick;                          // shadows the formal
            wick = "inner";
            m_sink.stow(wick);                    // s_shad  d1 (block local)
         end
         if (flap) begin
            int knob;                             // shadows an int formal
            knob = 2;
            m_sink.stow(knob);                    // s_shad2 d1
         end
      endfunction

      // ---- § 57's carve-out: an UNNAMED-block local at the SAME depth ------
      function void blk_fn(string wick);
         if (flap) begin
            string msg;                           // block local, SAME depth
            msg = "m";
            m_sink.stow(msg);                     // b_blk   d1  <-- § 57 cell
            m_sink.stow(wick);                    // b_farg  d1
         end
         begin
            string msg2;                          // block local at depth 0
            msg2 = "n";
            m_sink.stow(msg2);                    // b_blk0  d0
         end
      endfunction

      // ---- argument SHAPES outside § droppedCall14's accepted forms --------
      function void forms_fn(string wick, int knob);
         m_sink.stow(knob + 1);                   // x_expr  d0 (not re-emitted)
         m_sink.stow(m_vec[knob]);                // x_idx   d0 (not re-emitted)
         if (flap) begin
            m_sink.stow(knob + 1);                // x_expr1 d1
            m_sink.stow(m_vec[knob]);             // x_idx1  d1
         end
      endfunction

      // ---- ARITY: one, two, three actuals, mixed kinds --------------------
      function void arity_fn(string wick, int knob, int cogs);
         m_sink.stow(wick);                       // a1_0 d0
         m_sink.stow(wick, knob);                 // a2_0 d0
         m_sink.stow(wick, knob, cogs);           // a3_0 d0
         m_sink.stow(wick, m_dial, depot_glob);   // a3m_0 d0 formal/prop/pkg
         if (flap) begin
            m_sink.stow(wick);                    // a1_1 d1
            m_sink.stow(wick, knob);              // a2_1 d1
            m_sink.stow(wick, knob, cogs);        // a3_1 d1
            m_sink.stow(wick, m_dial, depot_glob);// a3m_1 d1
         end
      endfunction

      // ---- a for-loop ITERATOR as the actual --------------------------------
      function void iter_fn(string wick);
         for (int step = 0; step < 3; step++) begin
            m_sink.stow(step);                    // i_iter d1 (loop var)
            m_sink.stow(wick);                    // i_farg d1
         end
      endfunction
   endclass
endpackage
