package p8;
  class c8;
    int m_i;
    // a STATIC class method (allowed) — its locals
    static function int sf();
      begin
        automatic int q_sfauto = 1;
        int           q_sfplain = 2;
        sf = q_sfauto + q_sfplain;
      end
    endfunction
    task t_const();
      begin
        // `const automatic int` is UH0701-UNSUPPORTED in Surelog (golden
        // emits NO object for it), same family as `var automatic`.
        automatic int       q_auto  = 2;
        m_i = q_auto;
      end
    endtask
  endclass
endpackage
module m8;
  int mi;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g8
      task t_g();
        begin
          automatic int q_gtauto = 1;      // task inside a generate-for
          int           q_gtplain = 2;
          mi = q_gtauto + q_gtplain;
        end
      endtask
      initial t_g();
    end
  endgenerate
  initial begin
    automatic int q_rcauto = 1;
    randcase
      1: begin
           automatic int q_rc2 = 2;        // randcase item begin
           mi = q_rc2;
         end
      1: mi = q_rcauto;
    endcase
  end
endmodule
// (checker `initial` cannot hold a declaration statement in slang; the
//  checker cell is therefore not measurable here.)
