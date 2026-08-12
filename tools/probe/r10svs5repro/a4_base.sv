// r10svs5 ARM 4 — THE BASE of the vif access: `this.`-qualified, an ARRAY of
// virtual interfaces, a vif passed as a task ARGUMENT, a vif LOCAL to the task,
// and a NESTED interface instance inside the interface (the only shape that can
// collapse TWO components at once).
interface iface_inner(input bit clock);
  logic isig;
  clocking icb@(posedge clock);
    default input #1 output #1;
    output isig;
  endclocking
  modport IN(clocking icb, input clock);
endinterface

interface iface_d(input bit clock);
  logic       ds;
  logic [7:0] din;
  iface_inner sub(clock);     // f6: a nested INTERFACE INSTANCE

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
  endclocking

  modport IP(clocking cb, input clock);
endinterface

class drv_d;
  virtual iface_d.IP vif;
  virtual iface_d.IP varr[2];   // f2: an ARRAY of virtual interfaces
  virtual iface_d    vfull;

  task go(virtual iface_d.IP a);   // f3: a vif ARGUMENT
    virtual iface_d.IP loc;        // f4: a LOCAL vif
    loc = vif;
    // f1  `this.`-QUALIFIED base
    this.vif.cb.ds <= 1;
    // f2  an ARRAY element base
    varr[0].cb.ds <= 1;
    // f3  a task ARGUMENT base
    a.cb.ds <= 1;
    // f4  a LOCAL variable base
    loc.cb.din <= 8'h7;
    // f5  the plain class-property base (the SVSwitch witness shape) for
    //     side-by-side comparison in the same task
    vif.cb.din <= 8'h8;
    // f6  a NESTED interface instance THEN its clocking block: TWO collapsed
    //     components in one reference
    vfull.sub.icb.isig <= 1;
    // f7  the nested interface instance's signal RAW (one collapsed component)
    vfull.sub.isig <= 1;
    // f8  NEGATIVE CONTROL: `this.`-qualified NON-clocking member
    @(posedge this.vif.clock);
  endtask
endclass

module top_d;
  bit clock = 0;
  iface_d i_d(clock);
  drv_d d;
  initial begin
    d = new();
    d.vif = i_d;
    d.varr[0] = i_d;
    d.vfull = i_d;
    d.go(i_d);
  end
endmodule
