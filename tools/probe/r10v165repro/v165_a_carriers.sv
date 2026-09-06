// r10v165 ADVERSARIAL arm A — every CONTROL CARRIER r10uvm165's own arms did
// not spell, plus the DISTINGUISHER PAIR the brief asked for (ONE method
// carrying the SAME call at the top level AND inside a nested if).
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
// Names deliberately unlike the implementer's (no *165 suffix on cells, no
// tag_nm/perch/absent reuse of ordering) so an agreeing cell is not agreeing
// by construction.

package vpk_a;

   int   silo_glob;

   class Carrier #( type Tsink = int );
      Tsink      m_sink;
      static bit flap;
      int        m_dial;
      string     m_row[$];

      // ---------------- the DISTINGUISHER PAIR, one method ----------------
      // Same receiver, same method, same single argument, three depths, in a
      // SINGLE in-body class method.  If the law is depth, p0 stays bound and
      // p1/p2/p3 go bare; nothing else can produce that pattern.
      function void pair_probe(string wick);
         m_sink.stow(wick);                       // p0  d0
         if (flap) begin
            m_sink.stow(wick);                    // p1  d1
            if (m_dial == 7) begin
               m_sink.stow(wick);                 // p2  d2
               if (m_dial == 9) begin
                  m_sink.stow(wick);              // p3  d3
               end
            end
         end
      endfunction

      // ---------------- carriers arm D did NOT spell ----------------------
      function void carriers_fn(int knob, string wick);
         // case with a NON-default item and a DEFAULT item
         case (knob)
           1: m_sink.stow(wick);                  // c_case1   d1
           2: begin m_sink.stow(wick); end        // c_case2   d1 + begin
           default: m_sink.stow(wick);            // c_casedef d1
         endcase
         // casez / casex
         casez (knob)
           32'b?: m_sink.stow(wick);              // c_casez   d1
         endcase
         casex (knob)
           32'bx: m_sink.stow(wick);              // c_casex   d1
         endcase
         // unique / priority if
         unique if (knob == 3) m_sink.stow(wick); // c_uniq    d1
         priority if (knob == 4) m_sink.stow(wick); // c_prio  d1
         // else-if CHAIN: how many bodies deep is the second arm?
         if (knob == 5) m_sink.stow(wick);        // c_ei_a    d1
         else if (knob == 6) m_sink.stow(wick);   // c_ei_b    d?  (chain)
         else m_sink.stow(wick);                  // c_ei_c    d?  (final else)
         // a NAMED block INSIDE an if body (named block raises no depth of its
         // own, but the if did)
         if (flap) begin : nblk_a
            m_sink.stow(wick);                    // c_nblk    d1
         end
         // a fork arm inside an if body
         if (flap) begin
            fork
               m_sink.stow(wick);                 // c_fork    d1
            join_none
         end
         // a plain begin at TOP level must keep binding
         begin
            m_sink.stow(wick);                    // c_topbeg  d0
         end
      endfunction

      // forever / do-while need a task (a function may not hold a forever in
      // every tool); repeat and while live here too.
      task carriers_tk(int knob, string wick);
         int spin;
         forever begin
            m_sink.stow(wick);                    // t_forever d1
            break;
         end
         spin = 0;
         do begin
            m_sink.stow(wick);                    // t_dowhile d1
            spin++;
         end while (spin < 2);
         repeat (2) m_sink.stow(wick);            // t_repeat  d1
         while (spin < 4) begin
            m_sink.stow(wick);                    // t_while   d1
            spin++;
         end
         for (int q = 0; q < 2; q++)
            m_sink.stow(wick);                    // t_for     d1
         foreach (m_row[q])
            m_sink.stow(wick);                    // t_foreach d1
         m_sink.stow(wick);                       // t_top     d0
      endtask

      // a WAIT / disable-fork carrier: neither raises a control body
      task carriers_wt(string wick);
         m_sink.stow(wick);                       // w_top     d0
         if (flap) begin
            m_sink.stow(wick);                    // w_d1      d1
         end
      endtask
   endclass
endpackage
