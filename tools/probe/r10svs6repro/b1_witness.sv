// r10svs6 arm b1 — THE TWO SVSwitch WITNESSES, standalone, beside their
// already-converged SCALAR controls.
//   SVSwitch Environemnt.sv:17  `virtual output_interface.OP output_intf[4];`
//   SVSwitch Environemnt.sv:20  `Receiver rcvr[4];`
// The scalar twins are the controls: a virtual-interface property is already a
// bare logic_var (§ virtualIfacePropIsBareLogicVar6) and a class-handle property
// is already a class_var, so any disagreement in THIS arm is about the ARRAY.
// Module twins carry the m-prefix cells: the module-scope fixed-array emitter
// (TypeEmit.cpp emitArrayVar) already exists, so those cells say whether the
// class arm may route through it.
interface out_if;
  logic clk;
  logic rd;
  logic [7:0] dat;
  clocking cb @(posedge clk);
    output rd;
    input dat;
  endclocking
  modport OP(clocking cb, input clk);
endinterface

class Recv;
  int id;
endclass

class b1_env;
  virtual out_if.OP c01_vifarr[4];  // WITNESS 1
  Recv c02_hndarr[4];               // WITNESS 2
  virtual out_if.OP c03_vifsc;      // control: scalar vif
  Recv c04_hndsc;                   // control: scalar handle
  int c05_intarr[4];                // control: plain atom element
endclass

module b1_top;
  Recv m02_hndarr[4];
  Recv m04_hndsc;
  int m05_intarr[4];
  b1_env e;
endmodule
