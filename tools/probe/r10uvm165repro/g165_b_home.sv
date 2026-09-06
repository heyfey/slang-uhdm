// r10uvm165 arm B — THE HOME AND POSITION MATRIX FOR A **DROPPED** CALL.
//
// § droppedCall14 re-emits a STATEMENT-position dotted call that slang
// REJECTED, from the SYNTAX, and binds its plain-identifier arguments.  The
// rejection is triggered exactly the way the corpus triggers it: the receiver's
// declared type is an UNSPECIALIZED type PARAMETER, so the member lookup fails
// in the DEFAULT SPECIALIZATION and slang suppresses the diagnostic (a
// concrete-type "no member" spelling is a HARD ERROR and would reject the file).
//
// Down each column the HOME varies and nothing else.  MEASUREMENT ONLY.
// LHS is always golden (Surelog), RHS always ours.
package hpk165;

  class Sable165;
     function void keep(string nm); endfunction
  endclass

  int pkg_gauge165;

  class InBody165 #( type Timp = int );      // package home
     Timp     m_imp;
     static bit gate;
     static Timp s_imp;
     static int  s_perch;

     static function void run(string tag_nm);
        Timp     loc_imp;
        int      perch = 4;
        Sable165 pelt = null;

        s_imp.absent(tag_nm);                   // h01 d0   formal
        s_imp.absent(perch);                    // h02 d0   body local
        s_imp.absent(s_perch);                  // h03 d0   class STATIC property
        s_imp.absent(pkg_gauge165);             // h04 d0   PACKAGE variable
        loc_imp.absent(tag_nm);                 // h05 d0   LOCAL-handle receiver
        pelt.keep(tag_nm);                      // h06 d0   the VALID control
        begin
           s_imp.absent(tag_nm);                // h07 d0   plain begin (transparent)
           pelt.keep(tag_nm);                   // h08 d0   valid control
        end
        if (gate) begin
           s_imp.absent(tag_nm);                // h11 d1   formal
           s_imp.absent(perch);                 // h12 d1   body local
           pelt.keep(tag_nm);                   // h13 d1   the VALID control
        end
        if (gate) begin
           if (perch == 2) begin
              s_imp.absent(tag_nm);             // h14 d2   the CORPUS shape
           end
        end
        else begin
           s_imp.absent(tag_nm);                // h15 d1   ELSE arm
        end
        while (gate) begin
           s_imp.absent(tag_nm);                // h16 d1   while body
        end
        for (int k = 0; k < 2; k++) begin
           s_imp.absent(tag_nm);                // h17 d1   for body
        end
        case (perch)
          1: s_imp.absent(tag_nm);              // h18 d1   case-item clause
          default: s_imp.absent(perch);         // h19 d1
        endcase
        repeat (2) begin
           s_imp.absent(tag_nm);                // h20 d1
        end
        hnb165: begin
           s_imp.absent(tag_nm);                // h21 d0   NAMED block
        end
        fork
           s_imp.absent(tag_nm);                // h22 d0   fork arm
        join_none
     endfunction

     function void meth(string tag_nm);         // NON-static in-body method
        m_imp.absent(tag_nm);                   // h31 d0
        if (gate) begin
           m_imp.absent(tag_nm);                // h32 d1
        end
     endfunction

     task tsk(string tag_nm);                   // in-body TASK
        if (gate) begin
           m_imp.absent(tag_nm);                // h42 d1
        end
        m_imp.absent(tag_nm);                   // h41 d0
     endtask

     function new(string tag_nm);               // CONSTRUCTOR
        m_imp.absent(tag_nm);                   // h51 d0
        if (gate) begin
           m_imp.absent(tag_nm);                // h52 d1
        end
     endfunction

     extern function void oob(string tag_nm);
  endclass

  function void InBody165::oob(string tag_nm);  // OUT-OF-BODY definition
     m_imp.absent(tag_nm);                      // h61 d0
     if (gate) begin
        m_imp.absent(tag_nm);                   // h62 d1
     end
  endfunction
endpackage

module modhome165;
  import hpk165::*;

  class ModCls165 #( type Timp = int );         // class homed in a MODULE
     Timp m_imp;
     static bit gate;
     function void run(string tag_nm);
        m_imp.absent(tag_nm);                   // h71 d0
        if (gate) begin
           m_imp.absent(tag_nm);                // h72 d1
        end
     endfunction
  endclass
endmodule
