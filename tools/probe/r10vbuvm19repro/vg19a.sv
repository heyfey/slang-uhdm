// vbuvm19 adversarial grid A — THE HOME AXIS.
// Every cell has the SAME shape as BuildUVMPkg's converting site: a foreach
// over an array, with a SELECT assignment of the same bare name as a direct
// statement of an ancestor block.  Only the HOME changes.
package vhp19;

  class vbase19;
    int z19;
  endclass

  class vc19;
    vbase19 pa19[int];
    extern function void oob19();
    extern task        oobt19();
    function void inb19();                       // IN-BODY (control)
      foreach (pa19[k]) if (pa19[k] != null) $display("inb");
      pa19[7] = null;
    endfunction
    static vbase19 sa19[int];
    static function void stat19();               // STATIC in-body
      foreach (sa19[k]) if (sa19[k] != null) $display("stat");
      sa19[7] = null;
    endfunction
    extern static function void statoob19();     // STATIC out-of-body
  endclass

  function void vc19::oob19();
    foreach (pa19[k]) if (pa19[k] != null) $display("oob");
    pa19[7] = null;
  endfunction

  task vc19::oobt19();
    foreach (pa19[k]) if (pa19[k] != null) $display("oobt");
    pa19[7] = null;
  endtask

  function void vc19::statoob19();
    foreach (sa19[k]) if (sa19[k] != null) $display("statoob");
    sa19[7] = null;
  endfunction

  int pkv19[string];

  // package TASK home
  task pkgtask19();
    foreach (pkv19[k]) $display("pkgtask", pkv19[k]);
    pkv19["a"] = 1;
  endtask

  // package function home (the free-function control)
  function void pkgfn19();
    foreach (pkv19[k]) $display("pkgfn", pkv19[k]);
    pkv19["b"] = 2;
  endfunction
endpackage

// ---- MODULE homes -----------------------------------------------------
module vmod19;
  int mv19[string];
  int mv219[string];
  int mv319[string];
  int mv419[string];

  function void modfn19();
    foreach (mv19[k]) $display("modfn", mv19[k]);
    mv19["c"] = 3;
  endfunction

  task modtask19();
    foreach (mv219[k]) $display("modtask", mv219[k]);
    mv219["d"] = 4;
  endtask

  initial begin
    foreach (mv319[k]) $display("modinit", mv319[k]);
    mv319["e"] = 5;
  end

  always @(*) begin
    foreach (mv419[k]) $display("modalw", mv419[k]);
    mv419["f"] = 6;
  end

  // generate-block home
  for (genvar gi19 = 0; gi19 < 2; gi19++) begin : gblk19
    int gv19[string];
    initial begin
      foreach (gv19[k]) $display("gen", gv19[k]);
      gv19["g"] = 7;
    end
  end
endmodule

// ---- INTERFACE home ---------------------------------------------------
interface vif19;
  int iv19[string];
  function void iffn19();
    foreach (iv19[k]) $display("iffn", iv19[k]);
    iv19["h"] = 8;
  endfunction
endinterface

// ---- PROGRAM home -----------------------------------------------------
program vprg19;
  int pv19[string];
  function void prgfn19();
    foreach (pv19[k]) $display("prgfn", pv19[k]);
    pv19["i"] = 9;
  endfunction
  initial prgfn19();
endprogram

module vtop19;
  vmod19 u19();
  vif19  w19();
endmodule
