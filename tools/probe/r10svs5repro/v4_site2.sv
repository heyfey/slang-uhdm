// r10svs5 VERIFIER ARM v4 — SITE 2 (`emitMixedHierPath`) is the ONE call site
// that splices a recovered component into a component list that ALREADY carries
// element SELECTS, so it is the one place a firing can produce a WRONG element
// list instead of declining.  The shipped grid executes SITE 2 with exactly ONE
// cell (a4 f2, `varr[0].cb.ds <= 1`, an lvalue with a select on the BASE and no
// select on the leaf).  Never built: the rvalue form, a select on the LEAF as
// well as the base, a range select on the leaf, a 2-D base select, and the same
// through a nested interface instance.
interface iface_v4(input bit clock);
  logic       ds;
  logic [7:0] din;
  logic [7:0] dout;

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
    input  dout;
  endclocking

  modport IP(clocking cb, input clock);
endinterface

class drv_v4;
  virtual iface_v4.IP varr[2];
  virtual iface_v4.IP v2d[2][2];
  logic [7:0] r;

  task go();
    // v4a CONTROL (== a4 f2): lvalue, select on the BASE only
    varr[0].cb.ds <= 1;
    // v4b RVALUE with a select on the base
    r = varr[1].cb.dout;
    // v4c a select on the BASE *and* a bit select on the LEAF
    varr[0].cb.din[3] <= 1;
    // v4d a select on the BASE and a RANGE select on the leaf
    varr[1].cb.din[3:0] <= 4'h5;
    // v4e a TWO-DIMENSIONAL base select
    v2d[0][1].cb.ds <= 1;
    // v4f rvalue, base select, leaf bit select
    r[0] = varr[0].cb.dout[2];
  endtask
endclass

module top_v4;
  bit clock = 0;
  iface_v4 i_v(clock);
  drv_v4 d;
  initial begin
    d = new();
    d.varr[0] = i_v;
    d.varr[1] = i_v;
    d.v2d[0][1] = i_v;
    d.go();
  end
endmodule
