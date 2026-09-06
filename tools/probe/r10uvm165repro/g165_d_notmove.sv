// r10uvm165 arm D — THE MUST-STAY MATRIX, plus § droppedIdxRecvCall26's
// SUBSCRIPTED-receiver twin of the same statement object.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package dpk165;

  class Tally165;
     function void note(string nm); endfunction
  endclass

  class Warren165 #( type Timp = int );
     Timp       m_imp;
     Timp       m_bank[4];
     static bit gate;

     // ---- § droppedCall14's OWN documented population: a whole method body
     // that is ONE dropped call at depth 0.  Those 133 SeqDriver sites are the
     // reason `bind = true` exists and they must not move.
     function void solo(string tag_nm);
        m_imp.absent(tag_nm);                   // n01 d0 sole body statement
     endfunction

     function void pair165(string tag_nm, int cog);
        m_imp.absent(tag_nm);                   // n02 d0
        m_imp.absent(cog);                      // n03 d0
     endfunction

     // ---- the SUBSCRIPTED receiver (§ droppedIdxRecvCall26) --------------
     function void idx(string tag_nm, int cog);
        m_bank[cog].absent(tag_nm);             // n11 d0  must keep binding
        if (gate) begin
           m_bank[cog].absent(tag_nm);          // n12 d1  must go bare
        end
     endfunction

     // ---- the depth-0 column through every transparent carrier ----------
     function void carriers(string tag_nm);
        begin
           m_imp.absent(tag_nm);                // n21 d0 plain begin
        end
        begin
           begin
              m_imp.absent(tag_nm);             // n22 d0 nested plain begins
           end
        end
        nblk165: begin
           m_imp.absent(tag_nm);                // n23 d0 NAMED block
        end
        fork
           m_imp.absent(tag_nm);                // n24 d0 fork arm
        join_none
     endfunction

     // ---- every control carrier at depth 1, one cell each ---------------
     function void bodies(string tag_nm, int cog);
        if (gate)
           m_imp.absent(tag_nm);                // n31 if, no begin
        else
           m_imp.absent(tag_nm);                // n32 else, no begin
        while (gate)
           m_imp.absent(tag_nm);                // n33 while
        do
           m_imp.absent(tag_nm);                // n34 do-while
        while (gate);
        repeat (2)
           m_imp.absent(tag_nm);                // n35 repeat
        for (int k = 0; k < 2; k++)
           m_imp.absent(tag_nm);                // n36 for
        foreach (m_bank[i])
           m_imp.absent(tag_nm);                // n37 foreach
        case (cog)
          0: m_imp.absent(tag_nm);              // n38 case item
          default: ;
        endcase
     endfunction
  endclass
endpackage
