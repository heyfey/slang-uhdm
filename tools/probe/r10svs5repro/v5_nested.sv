// r10svs5 VERIFIER ARM v5 — the ACCESS-KIND x NESTED-INSTANCE product.  The
// shipped grid crosses access kind with the CLOCKING-BLOCK sub-shape (a1) and
// crosses the nested-INSTANCE sub-shape with only ONE access kind (a4 f6/f7,
// nonblocking write).  The cell that matters most is an EVENT CONTROL whose LEAF
// is the nested instance's clocking block (`@(vfull.sub.icb)`): there the walk
// starts from a ClockingBlockSymbol whose parent scope is the nested InstanceBody,
// so clause (3) sees ONE component where the a1 c7 analogue saw NONE.
interface iface_inner5(input bit clock);
  logic       isig;
  logic [7:0] ibus;
  clocking icb@(posedge clock);
    default input #1 output #1;
    output isig;
    input  ibus;
  endclocking
  modport IN(clocking icb, input clock);
endinterface

interface iface_v5(input bit clock);
  logic ds;
  iface_inner5 sub(clock);
  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
  endclocking
  modport IP(clocking cb, input clock);
endinterface

class drv_v5;
  virtual iface_v5 vfull;
  logic [7:0] r;

  task go();
    // v5a EVENT CONTROL whose LEAF is the NESTED instance's clocking block
    @(vfull.sub.icb);
    // v5b RVALUE read through the nested instance's clocking block
    r = vfull.sub.icb.ibus;
    // v5c the nested instance's clocking var in a CONDITION
    if (vfull.sub.icb.ibus[0])
      r = 0;
    // v5d CALL ARGUMENT through the nested instance
    $display("%0d", vfull.sub.icb.ibus);
    // v5e the nested instance's RAW signal in an event control
    @(posedge vfull.sub.clock);
  endtask
endclass

module top_v5;
  bit clock = 0;
  iface_v5 i_v(clock);
  drv_v5 d;
  initial begin
    d = new();
    d.vfull = i_v;
    d.go();
  end
endmodule
