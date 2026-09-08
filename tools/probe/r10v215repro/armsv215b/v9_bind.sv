// r10v215 ADVERSARIAL ARM v9 — A BOUND INTERFACE (the brief's third view,
// beside top and nested).  ModuleEmit.cpp ~9727 emits a BOUND interface child
// through emitInterfaceInstance with NO connModport, and § bindIfaceTwinInParent46
// publishes it a SECOND time at the target instance's parent — two listings
// whose modport vectors must move together or not at all.
interface v9_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

module v9_dut;
  logic clk;
endmodule

module top;
  v9_dut u1();
  v9_dut u2();
endmodule

bind v9_dut v9_if b_if();
