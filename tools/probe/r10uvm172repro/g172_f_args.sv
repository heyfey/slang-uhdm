// r10uvm172 arm F — THE ARGUMENT AXIS of the collapsed call, plus the two
// roads the law must REFUSE.  MEASUREMENT ONLY.
package pk172;
  class fbase172;
    string  fq172[$];
    int     fn172;
    function void fadd172(string a, int b); fq172.push_back(a); fn172 = b; endfunction
  endclass

  class fuser172;
    string  fprop172;
    int     fpn172;

    function void ffn172(); endfunction
    task     ftk172(); endtask

    // The receiver spelling `ffn172` shadows this class's own function, so
    // every statement below collapses; the ARGUMENTS are the axis.
    function void fargs172(string aform172, int bform172);
      fbase172 ffn172;
      string   floc172;
      int      fint172;
      ffn172 = new();
      floc172 = "f";
      fint172 = 2;
      ffn172.fadd172(floc172, fint172);     // f01 two LOCAL identifier args
      ffn172.fadd172(aform172, bform172);   // f02 two FORMAL args
      ffn172.fadd172(fprop172, fpn172);     // f03 two CLASS PROPERTY args
      ffn172.fq172.push_back(floc172);      // f04 DEEP chain, an identifier arg
      ffn172.fadd172({floc172,"x"}, fint172+1); // f05 EXPRESSION args
      ffn172.fq172.push_back("lit");        // f06 DEEP chain, a literal arg
    endfunction

    // f07 — the SUBSCRIPTED BASE of a ONE-DEEP chain: Surelog's
    // `argListNode` lands on the WRITTEN list, so the arguments survive.
    function void fsub172();
      fbase172 ffn172[4];
      ffn172[1] = new();
      ffn172[1].fadd172("f07", 7);
    endfunction

    // f08 — a TASK receiver name in a TASK home.
    task ftask172();
      fbase172 ftk172;
      ftk172 = new();
      ftk172.fadd172("f08", 8);
    endtask
  endclass
endpackage

module topf172;
  import pk172::*;
  // f09 — a MODULE function name used as a receiver INSIDE AN INITIAL BLOCK
  // (no enclosing subroutine at all).
  function int fmodfn172(); return 1; endfunction
  fbase172 fmodfn172v;
  fuser172 fu172;

  initial begin
    fbase172 fmodfn172;
    fmodfn172 = new();
    fmodfn172.fq172.push_back("f09");
    fu172 = new();
    fu172.fargs172("a", 1);
    fu172.fsub172();
    fu172.ftask172();
  end
endmodule
