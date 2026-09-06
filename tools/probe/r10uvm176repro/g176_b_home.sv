// r10uvm176 arm B — THE HOMES.  The SAME statement-position call through an
// interface handle, written in every home the emitter distinguishes:
// in-body class method / OUT-OF-BODY class method / $unit class / package
// class / a MODULE function / a module procedural block / an INTERFACE's own
// subroutine.  MEASUREMENT ONLY.
interface link_if176;
   int  ctr176;
   function automatic void bump176(int amt176);
      ctr176 = ctr176 + amt176;
   endfunction
   task automatic hold176(int amt176);
      ctr176 = amt176;
   endtask
endinterface

// ---- $unit-scope class ------------------------------------------------
class unitrider176;
   virtual link_if176 duct176;
   function void u1_inbody(int papa176);
      duct176.bump176(papa176);           // c_unit_inbody
   endfunction
endclass

package deck176;
   // ---- package class, IN-BODY method ---------------------------------
   class pkgrider176;
      virtual link_if176 duct176;
      int roll176;
      function void p1_inbody(int quebec176);
         duct176.bump176(quebec176);      // c_pkg_inbody
      endfunction
      // ---- package class, OUT-OF-BODY method (prototype here) ---------
      extern function void p2_oob(int romeo176);
      extern task p3_oobtask(int sierra176);
   endclass

   function void pkgrider176::p2_oob(int romeo176);
      duct176.bump176(romeo176);          // c_pkg_oob
   endfunction

   task pkgrider176::p3_oobtask(int sierra176);
      duct176.hold176(sierra176);         // c_pkg_oobtask
   endtask
endpackage

module holder176(link_if176 port176);     // an interface PORT — the arm's
                                          // ORIGINAL decode; must NOT move
   int tango176;

   // ---- a MODULE-scope function ---------------------------------------
   function void m1_modfn(int uniform176);
      port176.bump176(uniform176);        // c_mod_fn
   endfunction

   // ---- a module PROCEDURAL block --------------------------------------
   initial begin
      int victor176;
      victor176 = 3;
      port176.bump176(victor176);         // c_mod_proc
      m1_modfn(tango176);
   end
endmodule

interface caller_if176;
   link_if176 nested176();
   // ---- an INTERFACE's own subroutine calling a nested interface -------
   function automatic void i1_ifacefn(int whisky176);
      nested176.bump176(whisky176);       // c_iface_fn
   endfunction
endinterface

module top176;
   link_if176   wirebox176();
   holder176    hold_u176(.port176(wirebox176));
   caller_if176 call_u176();
   unitrider176 uu176;
   deck176::pkgrider176 pp176;
   initial begin
      uu176 = new();
      uu176.duct176 = wirebox176;
      uu176.u1_inbody(1);
      pp176 = new();
      pp176.duct176 = wirebox176;
      pp176.p1_inbody(2);
      pp176.p2_oob(3);
      pp176.p3_oobtask(4);
      call_u176.i1_ifacefn(5);
   end
endmodule
