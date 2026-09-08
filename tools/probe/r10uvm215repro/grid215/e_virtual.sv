// r10uvm215 GRID ARM E — THE CORPUS SHAPE ITSELF, minimised.  SeqDriver's
// `adpcm_if` verbatim in structure (four nets, a clocking block with two inout
// items, one clocking-only modport) plus the class that holds it as a VIRTUAL
// INTERFACE QUALIFIED BY THAT MODPORT — the reference that would dangle if the
// modport object were dropped without golden agreeing.
//
// e1 the SeqDriver interface + a virtual-interface class member
// e2 the same interface with a SIMPLE-PORT modport added beside the clocking
//    one, held virtually through the SIMPLE one (the control)

interface e1_if;
  logic clk;
  logic frame;
  logic [3:0] data;
  logic bozo;
  clocking cb @(posedge clk);
    inout frame;
    inout data;
  endclocking
  modport mon_mp (clocking cb);
endinterface

interface e2_if;
  logic clk;
  logic frame;
  logic [3:0] data;
  clocking cb @(posedge clk);
    inout frame;
    inout data;
  endclocking
  modport mon_mp (clocking cb);
  modport drv_mp (input clk, output frame);
endinterface

class e1_holder;
  virtual e1_if.mon_mp vif;
  function void put(virtual e1_if.mon_mp v);
    vif = v;
  endfunction
endclass

class e2_holder;
  virtual e2_if.drv_mp vif;
endclass

module top;
  e1_if i1();
  e2_if i2();
  e1_holder h1;
  e2_holder h2;
  initial begin
    h1 = new();
    h2 = new();
    h1.put(i1.mon_mp);
  end
endmodule
