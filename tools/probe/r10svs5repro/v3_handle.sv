// r10svs5 VERIFIER ARM v3 — the HANDLE-KIND / SCOPE-WALK product the grid
// leaves empty.  Clause (2) is an ALLOWLIST of ClockingBlock + InstanceBody; the
// shipped arms execute the allowlist's ACCEPT side (a4 f6/f7) and one DECLINE
// (a modport port symbol, a3 e5/e6).  Never built: a GENERATE BLOCK inside the
// interface, a nested MODULE instance inside the interface, an interface INSTANCE
// ARRAY inside the interface, a TYPEDEF'd virtual-interface type (clause (1) is a
// canonical-type test and no cell proves the typedef is seen through), a vif
// reached through ANOTHER object's property or through a struct member
// (chain.size() > 1 — declined silently, and only `this.`-rooted was measured),
// and a STATIC class property.
interface iface_leaf(input bit clock);
  logic lsig;
  clocking lcb@(posedge clock);
    default input #1 output #1;
    output lsig;
  endclocking
  modport LP(clocking lcb, input clock);
endinterface

interface iface_v3(input bit clock);
  logic ds;
  parameter int N = 2;

  iface_leaf lf(clock);           // nested interface INSTANCE (a4 f6/f7 shape)
  iface_leaf lfa[2](clock);       // nested interface INSTANCE ARRAY -- NEW

  if (1) begin : gblk             // a GENERATE BLOCK in the interface -- NEW
    logic gsig;
  end

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
  endclocking

  modport IP(clocking cb, input clock);
endinterface

typedef virtual iface_v3 vif_t;   // a TYPEDEF'd virtual-interface type -- NEW

class holder;
  virtual iface_v3 h;
endclass

class drv_v3;
  virtual iface_v3   vfull;
  vif_t              vtd;         // via the typedef
  static virtual iface_v3 vstat;  // a STATIC class property
  holder             ho;

  task go();
    // v3a CONTROL: the plain firing shape through the un-modported handle
    vfull.cb.ds <= 1;
    // v3b the same through a TYPEDEF'd vif type (clause (1) canonical test)
    vtd.cb.ds <= 1;
    // v3c the same through a STATIC class property
    vstat.cb.ds <= 1;
    // v3d a GENERATE BLOCK component inside the interface
    vfull.gblk.gsig <= 1;
    // v3f a nested interface INSTANCE ARRAY element, then its clocking block
    vfull.lfa[0].lcb.lsig <= 1;
    // v3g a vif reached through ANOTHER OBJECT's property (chain.size() == 2)
    ho.h.cb.ds <= 1;
  endtask
endclass

module top_v3;
  bit clock = 0;
  iface_v3 i_v(clock);
  drv_v3 d;
  initial begin
    d = new();
    d.vfull = i_v;
    d.vtd   = i_v;
    d.ho    = new();
    d.ho.h  = i_v;
    d.go();
  end
endmodule
