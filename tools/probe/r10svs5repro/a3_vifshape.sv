// r10svs5 ARM 3 — the SHAPES of the vif access itself: selects over a clocking
// var, the vif WITHOUT a modport, a modport WITHOUT clocking, a RENAMED clocking
// item, the same signal reached BOTH ways, and a NESTED interface inside the
// interface (the deepest collapse slang can hand us).
interface iface_inner(input bit clock);
  logic       isig;
  clocking icb@(posedge clock);
    default input #1 output #1;
    output isig;
  endclocking
  modport IN(clocking icb, input clock);
endinterface

interface iface_c(input bit clock);
  logic       ds;
  logic [7:0] din;
  logic [7:0] dout;
  logic       raw;

  // e7: a clocking item RENAMED from the underlying signal.
  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
    input  dout;
    output alias_ds = ds;
  endclocking

  modport IP(clocking cb, output raw, input clock);
  modport NOCB(output ds, input clock);
endinterface

class drv_c;
  virtual iface_c.IP  vif;     // modport WITH clocking
  virtual iface_c     vfull;   // NO modport at all
  virtual iface_c.NOCB vnocb;  // modport WITHOUT clocking
  logic [7:0] r;

  task go();
    // e1  ELEMENT SELECT over a clocking var (lvalue)
    vif.cb.din[3] <= 1;
    // e2  RANGE SELECT over a clocking var (lvalue)
    vif.cb.din[3:0] <= 4'h5;
    // e3  ELEMENT SELECT over a clocking var (rvalue)
    r = vif.cb.dout[2];
    // e4  vif with NO modport
    vfull.cb.ds <= 1;
    // e5  NEGATIVE CONTROL: modport WITHOUT clocking, raw signal
    vnocb.ds <= 1;
    // e6  NEGATIVE CONTROL: a plain modport member on the clocking modport
    vif.raw <= 1;
    // e7  a RENAMED clocking item
    vif.cb.alias_ds <= 1;
    // e8  the SAME signal reached raw through the full handle
    vfull.ds <= 1;
    // e9  and through its clocking block, same task
    vfull.cb.din <= 8'h2;
    // e10 event control on the clocking block through the un-modported handle
    @(vfull.cb);
  endtask
endclass

module top_c;
  bit clock = 0;
  iface_c i_c(clock);
  iface_inner i_i(clock);
  drv_c d;
  initial begin
    d = new();
    d.vif   = i_c;
    d.vfull = i_c;
    d.vnocb = i_c;
    d.go();
  end
endmodule
