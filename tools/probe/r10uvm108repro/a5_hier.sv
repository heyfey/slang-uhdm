// r10uvm108 GRID arm 5 -- the shapes whose BASE NAME is not a plain local:
// a HIERARCHICAL path through an instance, a `::`-scoped name, a VIRTUAL
// INTERFACE handle and a clocking block.  These are the corpus shapes the
// predictor found outside the UVM tree (Google chapter-15 `@top.e;`,
// Icarus pr572 `@top.toplevel_event`, Monitor `@_if.cb;`,
// Opentitan rv_timer `@cfg.clk_rst_vif.cb;`), written here in their
// DEPTH-ZERO form so the window is open and only the SYMBOL can decide.
package hr108_pkg;
  event scopedEvent;
  class cage108;
    event caged;
  endclass
endpackage

interface hr108_if(input logic clk);
  logic ready;
  clocking cb @(posedge clk);
    input ready;
  endclocking
endinterface

module hr108_leaf;
  event leafEvent;
  logic leafSig;
endmodule

class hr108_watch;
  virtual hr108_if  vifProp;
  hr108_pkg::cage108 cageProp;

  // g01 -- a VIRTUAL INTERFACE class property, clocking block leaf
  task automatic g01_vifprop();
    @vifProp.cb;
  endtask

  // g02 -- a virtual interface FORMAL, clocking block leaf
  task automatic g02_vifformal(virtual hr108_if arg02);
    @arg02.cb;
  endtask

  // g03 -- a virtual interface TASK LOCAL, clocking block leaf
  task automatic g03_viflocal();
    virtual hr108_if loc03;
    @loc03.cb;
  endtask

  // g04 -- a `::`-scoped package event (NOT a dot path)
  task automatic g04_scoped();
    @hr108_pkg::scopedEvent;
  endtask
endclass

module hr108_top;
  hr108_leaf u_leaf();
  logic clk;
  hr108_if u_if(clk);
  event    topEvent;

  // g05 -- a HIERARCHICAL path through a child INSTANCE
  initial @u_leaf.leafEvent;

  // g06 -- the same from inside a task
  task automatic g06_hier();
    @u_leaf.leafSig;
  endtask

  // g07 -- a hierarchical path to an INTERFACE instance's clocking block
  initial @u_if.cb;

  // g08 -- the module's OWN event, bare (the positive control)
  initial @topEvent;
endmodule
