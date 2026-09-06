// r10v176 arm P — VERIFIER.  The faces r10uvm176's own arms never wrote:
// a MODPORT-typed virtual interface, a class nested INSIDE a module, a
// CONSTRUCTOR home, a class holding TWO and THREE handles, and a plain
// (non-virtual) interface receiver reached from an interface's own class.
// MEASUREMENT ONLY.  LHS is always golden (Surelog); RHS is always ours.
interface chan_qq (input logic clk_qq);
   int      slot_qq;
   string   tagline_QQ;
   modport  drv_qq (import punch_qq, import shove_qq, output slot_qq);
   function automatic void punch_qq(int amount_QQ);
      slot_qq = amount_QQ;
   endfunction
   task automatic shove_qq(int amount_QQ);
      slot_qq = amount_QQ + 1;
   endtask
endinterface

class Rider_QQ;
   virtual chan_qq          full_qq;    // whole-interface handle
   virtual chan_qq.drv_qq   port_qq;    // MODPORT-typed handle  <-- the face
   int                      ledger_QQ;

   // P1 — a modport-typed vif, statement position, argument is the FORMAL.
   function void p1_modport(int quill_QQ);
      port_qq.punch_qq(quill_QQ);            // m_modport_fn
   endfunction

   // P2 — the same through the modport handle, TASK.
   task p2_modtask(int rasp_QQ);
      port_qq.shove_qq(rasp_QQ);             // m_modport_tk
   endtask

   // P3 — the CONTROL: the same call through the WHOLE-interface handle.
   function void p3_whole(int satchel_QQ);
      full_qq.punch_qq(satchel_QQ);          // m_whole_fn
   endfunction

   // P4 — a CONSTRUCTOR home (interacts with § ctor...NoBind144).
   function new(int tuck_QQ);
      ledger_QQ = 0;
      full_qq.punch_qq(tuck_QQ);             // m_ctor
   endfunction

   // P5 — the distinguisher PAIR inside ONE subroutine: one call at top
   // level and one nested in an `if`, same formal, same receiver.
   function void p5_pair(int vellum_QQ);
      full_qq.punch_qq(vellum_QQ);           // m_pair_top   (depth 0)
      if (ledger_QQ != 0) begin
         full_qq.punch_qq(vellum_QQ);        // m_pair_deep  (depth 1)
      end
   endfunction
endclass

// ---- a class nested INSIDE A MODULE (a home arm B never wrote) ----------
module carrier_QQ (input logic clk_qq);
   chan_qq wired_qq (.clk_qq(clk_qq));

   class Inner_QQ;
      virtual chan_qq stub_qq;
      function void n1_modhome(int wharf_QQ);
         stub_qq.punch_qq(wharf_QQ);         // m_modclass
      endfunction
   endclass

   // the module-FUNCTION control that MUST NOT move
   function void n2_modfn(int xenon_QQ);
      wired_qq.punch_qq(xenon_QQ);           // m_modfn_ctl
   endfunction

   Inner_QQ    kid_QQ;
   Rider_QQ    one_QQ, two_QQ, three_QQ;     // 1-3 instances of the class
   initial begin
      kid_QQ = new();
      kid_QQ.stub_qq = wired_qq;
      kid_QQ.n1_modhome(11);
      n2_modfn(12);
      one_QQ   = new(1);
      two_QQ   = new(2);
      three_QQ = new(3);
      one_QQ.full_qq   = wired_qq;
      two_QQ.full_qq   = wired_qq;
      three_QQ.full_qq = wired_qq;
      one_QQ.port_qq   = wired_qq.drv_qq;
      two_QQ.port_qq   = wired_qq.drv_qq;
      three_QQ.port_qq = wired_qq.drv_qq;
      one_QQ.p1_modport(21);
      two_QQ.p3_whole(22);
      three_QQ.p5_pair(23);
   end
endmodule

module tb_QQ;
   logic clk_qq = 0;
   carrier_QQ u_first_QQ  (.clk_qq(clk_qq));
   carrier_QQ u_second_QQ (.clk_qq(clk_qq));
   carrier_QQ u_third_QQ  (.clk_qq(clk_qq));
endmodule
