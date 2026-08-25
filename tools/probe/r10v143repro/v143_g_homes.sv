// r10v143 arm G — THE HOME AXIS on the binding shape.  One body,
//   if (tbl[k].tally == 0) $display(...);
// written in every home a hier_path element index can live in, with a
// defaulted formal as the index.  LHS IS ALWAYS GOLDEN.
package pkG143v;
  class Nub; int tally; int gauge; endclass

  Nub pkgTbl[int];
  task gpkg_tk(int k = 0);                 // free package task      -> DRAINED
    if (pkgTbl[k].tally == 0) $display("gpkg_tk");
  endtask
  function int gpkg_fn(int k = 0);         // free package function  -> DRAINED
    int r = 0;
    if (pkgTbl[k].tally == 0) r = 1;
    return r;
  endfunction

  virtual class GinPkg;                    // IN-BODY class method   -> NEVER
    Nub tbl[int];
    task gin_tk(int k = 0);
      if (tbl[k].tally == 0) $display("gin_tk");
    endtask
    function int gin_fn(int k = 0);
      int r = 0;
      if (tbl[k].tally == 0) r = 1;
      return r;
    endfunction
    pure virtual task gin_pure(int k);
  endclass

  class GinPkgC extends GinPkg;            // concrete child, in-body override
    task gin_pure(int k);
      if (tbl[k].gauge == 0) $display("gin_pure");
    endtask
  endclass

  class GoobPkg;                           // OUT-OF-BODY method     -> DRAINED
    Nub tbl[int];
    extern task goo_tk(int k = 0);
    extern function int goo_fn(int k = 0);
  endclass
  task GoobPkg::goo_tk(int k = 0);
    if (tbl[k].tally == 0) $display("goo_tk");
  endtask
  function int GoobPkg::goo_fn(int k = 0);
    int r = 0;
    if (tbl[k].tally == 0) r = 1;
    return r;
  endfunction

  class GouterPkg;                         // a class NESTED in a class
    class GinnerPkg;
      Nub tbl[int];
      task gnest_tk(int k = 0);
        if (tbl[k].tally == 0) $display("gnest_tk");
      endtask
    endclass
    Nub tbl[int];
    task gout_tk(int k = 0);
      if (tbl[k].tally == 0) $display("gout_tk");
    endtask
  endclass
endpackage

interface ifG143v;
  pkG143v::Nub ifTbl[int];
  task gif_tk(int k = 0);                  // an INTERFACE task
    if (ifTbl[k].tally == 0) $display("gif_tk");
  endtask
  class GinIf;                             // a class declared in an INTERFACE
    pkG143v::Nub tbl[int];
    task gifc_tk(int k = 0);
      if (tbl[k].tally == 0) $display("gifc_tk");
    endtask
  endclass
endinterface

module modG143v;
  import pkG143v::*;
  Nub modTbl[int];
  task gmod_tk(int k = 0);                 // a MODULE task          -> DRAINED
    if (modTbl[k].tally == 0) $display("gmod_tk");
  endtask
  function int gmod_fn(int k = 0);         // a MODULE function      -> DRAINED
    int r = 0;
    if (modTbl[k].tally == 0) r = 1;
    return r;
  endfunction
  class GinMod;                            // a class declared in a MODULE
    Nub tbl[int];
    task gmc_tk(int k = 0);
      if (tbl[k].tally == 0) $display("gmc_tk");
    endtask
    extern task gmc_oob(int k = 0);
  endclass
  task GinMod::gmc_oob(int k = 0);         // out-of-body inside a MODULE
    if (tbl[k].tally == 0) $display("gmc_oob");
  endtask

  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    Nub genTbl[int];
    task ggen_tk(int k = 0);               // a GENERATE-BLOCK task
      if (genTbl[k].tally == 0) $display("ggen_tk");
    endtask
  end

  GinMod  gm;
  GinPkgC gp;
  GoobPkg go;
  int n;
  initial begin
    gm = new(); gp = new(); go = new();
    gm.gmc_tk(); gp.gin_tk(); go.goo_tk(); gmod_tk(); gpkg_tk();
    n = gmod_fn(); n = gpkg_fn();
  end
endmodule

program progG143v;
  import pkG143v::*;
  Nub prgTbl[int];
  task gprg_tk(int k = 0);                 // a PROGRAM task
    if (prgTbl[k].tally == 0) $display("gprg_tk");
  endtask
  class GinPrg;                            // a class declared in a PROGRAM
    Nub tbl[int];
    task gpc_tk(int k = 0);
      if (tbl[k].tally == 0) $display("gpc_tk");
    endtask
  endclass
  GinPrg gpc;
  initial begin gpc = new(); gpc.gpc_tk(); gprg_tk(); end
endprogram

module topG143v;
  modG143v  u_m();
  ifG143v   u_i();
  progG143v u_p();
endmodule
