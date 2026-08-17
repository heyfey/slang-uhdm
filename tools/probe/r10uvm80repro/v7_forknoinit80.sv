// r10uvm80 VERIFIER arm v7 — the FORK / NO-INITIALISER quirk.  StmtEmit's block
// loop pushes the SAME variable object into Variables TWICE when the block is a
// `fork` and the declaration has no initialiser (a transcription of Surelog's
// par_block "handled" flag), so SITE 4's stamp lands on an object that is
// listed twice.  Does golden stamp BOTH listings?
package p7;
  class c7;
    int m_i;
    task t();
      fork
        automatic int k_fkauto;      // fork arm, automatic, NO init
      join_none
      fork
        int k_fkplain;               // fork arm, NO kw, NO init
      join_none
      fork : nf7
        automatic int k_nfauto;      // NAMED fork arm, automatic, NO init
      join_none
      begin
        automatic int k_bgauto;      // begin, automatic, NO init (control)
        m_i = k_bgauto;
      end
    endtask
  endclass
endpackage
module m7;
  int mi;
  initial fork
    automatic int m_fkauto;          // module fork arm, automatic, NO init
    int           m_fkplain;         // module fork arm, NO kw, NO init
  join_none
endmodule
