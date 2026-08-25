// r10v143 arm N — WHOSE ARRAY IS IT?  The law is about where the BODY was
// compiled, not where the indexed object lives.  Each in-body class method
// below indexes an array owned by somebody ELSE: the package, an outer module,
// a base class, a static class property, another class's static, a virtual
// interface.  If golden binds ANY of those inside a class body the patch is
// wrong.  Out-of-body twins where the shape allows.
package pkN143v;
  class Nit; int tally; int gauge; endclass
  Nit pkgTbl[int];                          // a PACKAGE-owned array
  class NBase;
    Nit baseTbl[int];                       // a BASE-CLASS-owned array
    static Nit statTbl[int];                // a STATIC class property
  endclass
  class NOther;
    static Nit otherStat[int];              // ANOTHER class's static
  endclass

  class NinN extends NBase;
    Nit ownTbl[int];
    task n01(int k = 0); if (pkgTbl[k].tally   == 0) $display("n01"); endtask
    task n02(int k = 0); if (baseTbl[k].tally  == 0) $display("n02"); endtask
    task n03(int k = 0); if (statTbl[k].tally  == 0) $display("n03"); endtask
    task n04(int k = 0); if (NOther::otherStat[k].tally == 0) $display("n04"); endtask
    task n05(int k = 0); if (pkN143v::pkgTbl[k].gauge == 0) $display("n05"); endtask
    task n06(int k = 0); if (ownTbl[k].tally == 0) $display("n06"); endtask
    task n07(int k = 0); if (super.baseTbl[k].gauge == 0) $display("n07"); endtask
    task n08(int k = 0); if (this.ownTbl[k].gauge == 0) $display("n08"); endtask
  endclass

  class NooN extends NBase;
    Nit ownTbl[int];
    extern task o01(int k = 0);
    extern task o02(int k = 0);
    extern task o03(int k = 0);
    extern task o06(int k = 0);
  endclass
  task NooN::o01(int k = 0); if (pkgTbl[k].tally  == 0) $display("o01"); endtask
  task NooN::o02(int k = 0); if (baseTbl[k].tally == 0) $display("o02"); endtask
  task NooN::o03(int k = 0); if (statTbl[k].tally == 0) $display("o03"); endtask
  task NooN::o06(int k = 0); if (ownTbl[k].tally  == 0) $display("o06"); endtask

  class NparN #(int PW = 1);                // a PARAMETERIZED class, 3 specializations
    Nit spTbl[int];
    task p01(int k = 0); if (spTbl[k].tally == 0) $display("p01"); endtask
    task p02();          if (spTbl[PW].tally == 0) $display("p02"); endtask
  endclass
endpackage

module modN143v;
  import pkN143v::*;
  Nit modTbl[int];                          // a MODULE-owned array
  class NinMod;
    task q01(int k = 0); if (modTbl[k].tally == 0) $display("q01"); endtask
    task q02(int k = 0); if (pkgTbl[k].tally == 0) $display("q02"); endtask
  endclass
  NinMod nm; NinN ni; NooN no;
  NparN #(1) s1; NparN #(2) s2; NparN #(3) s3;
  initial begin
    nm = new(); ni = new(); no = new(); s1 = new(); s2 = new(); s3 = new();
    nm.q01(); ni.n01(); no.o01(); s1.p01(); s2.p01(); s3.p01();
  end
endmodule
