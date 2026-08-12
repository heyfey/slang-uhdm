// r10svs5 VERIFIER ARM v1 — the DIRECTION axis the 45-cell grid never built.
// The brief asked for "input vs output vs inout clocking direction"; the arms
// shipped cover output (ds/din) and input (dout/rdy) but NEVER `inout`, and
// never an explicit per-item SKEW, and never a clockvar whose underlying signal
// is a 2-D/packed-array.  Every cell here is a vif access, i.e. the law's own
// domain, so an empty product here would be an unmeasured firing.
interface iface_v1(input bit clock);
  logic       io;
  logic       skewed;
  logic [7:0] arr2 [0:3];
  logic [3:0][7:0] pk;
  logic       o;

  clocking cb@(posedge clock);
    default input #1 output #1;
    inout  io;          // v1a  the INOUT clocking direction
    input  #2 skewed;   // v1b  an explicit per-item input SKEW
    output o;
    inout  pk;          // v1d  a packed 2-D clockvar
  endclocking

  modport IP(clocking cb, input clock);
endinterface

class drv_v1;
  virtual iface_v1.IP vif;
  logic       r;
  logic [7:0] q;

  task go();
    // v1a  WRITE through an INOUT clocking var
    vif.cb.io <= 1;
    // v1a2 READ through the same INOUT clocking var
    r = vif.cb.io;
    // v1b  READ of a SKEWED input clockvar
    r = vif.cb.skewed;
    // v1c  event control on an inout clockvar
    @(vif.cb.io);
    // v1d  a PACKED 2-D clockvar, whole-object write
    vif.cb.pk <= 32'h0;
    // v1e  an intra-assignment CLOCKING DRIVE with a cycle delay
    vif.cb.o <= ##2 1;
  endtask
endclass

module top_v1;
  bit clock = 0;
  iface_v1 i_v(clock);
  drv_v1 d;
  initial begin
    d = new();
    d.vif = i_v;
    d.go();
  end
endmodule
