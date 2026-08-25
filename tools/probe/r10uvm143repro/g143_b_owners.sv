// r10uvm143 arm B — THE OWNER AXIS of § hpIdxClassLateBindNeverDrained143.
// Surelog drains the late-binding pool for PACKAGES (UhdmWriter.cpp:1304) and
// MODULES (:1575/:1623/:2072) but the class call is COMMENTED OUT (:1066-1067),
// so a hier_path element's index reference binds in a package/module-scope body
// and stays bare in a body written INSIDE a class.
package Foundry_pkg;

  class Billet;
    int weight;
    int grade;
  endclass

  // ---- owner 1: IN-BODY class method (expect: NO vpiActual on the index)
  class InsideShop;
    Billet stock[Billet];
    Billet crate[int];
    task inbodyTask(Billet lot = null);
      if (stock[lot].weight == 0) $display("b1");
    endtask
    function int inbodyFunc(int bay = 2);
      return crate[bay].grade;
    endfunction
  endclass

  // ---- owner 2: OUT-OF-BODY (extern) class method, defined at package scope
  //      (expect: the index DOES carry a vpiActual)
  class OutsideShop;
    Billet stock[Billet];
    Billet crate[int];
    extern task oobTask(Billet lot = null);
    extern function int oobFunc(int bay = 2);
  endclass

  task OutsideShop::oobTask(Billet lot = null);
    if (stock[lot].weight == 0) $display("b2");
  endtask

  function int OutsideShop::oobFunc(int bay = 2);
    return crate[bay].grade;
  endfunction

  // ---- owner 3: a PROTOTYPE-ONLY method (pure virtual): NO body, so the arm
  //      records that it contributes no path-index cell at all on either side.
  virtual class StubShop;
    Billet stock[Billet];
    pure virtual task stubTask(Billet lot = null);
  endclass

  // ---- owner 4: a FREE package function / task (package scope)
  Billet pkgStock[Billet];
  Billet pkgCrate[int];

  function int freeFunc(int bay = 2);
    return pkgCrate[bay].grade;
  endfunction

  task freeTask(Billet lot = null);
    if (pkgStock[lot].weight == 0) $display("b4");
  endtask

endpackage

// ---- owner 5: a MODULE task and a module function
module foundryTop;
  import Foundry_pkg::*;
  Foundry_pkg::Billet modStock[Foundry_pkg::Billet];
  Foundry_pkg::Billet modCrate[int];

  task modTask(Foundry_pkg::Billet lot = null);
    if (modStock[lot].weight == 0) $display("b5");
  endtask

  function int modFunc(int bay = 2);
    return modCrate[bay].grade;
  endfunction

  Foundry_pkg::InsideShop shopA;
  Foundry_pkg::OutsideShop shopB;
  initial begin
    shopA = new();
    shopB = new();
    shopA.inbodyTask();
    shopB.oobTask();
  end
endmodule

// ---- owner 6: a PROGRAM task
program foundryProg;
  Foundry_pkg::Billet progStock[Foundry_pkg::Billet];
  task progTask(Foundry_pkg::Billet lot = null);
    if (progStock[lot].weight == 0) $display("b6");
  endtask
  initial progTask();
endprogram
