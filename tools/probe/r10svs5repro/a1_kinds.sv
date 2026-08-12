// r10svs5 ARM 1 — ACCESS KIND grid, through a VIRTUAL INTERFACE handle in a
// class (the witness shape: SVSwitch Driver.sv:53 `input_intf.cb.data_status <= 1`).
//
// One cell per access kind.  Every cell here is LEGAL SystemVerilog on both
// tools by construction: writes to clocking OUTPUT vars are nonblocking, reads
// are of clocking INPUT vars, and no cell mixes the two (a blocking write to a
// clocking var is a slang hard error `ClockVarSyncDrive`, so it lives in its own
// arm a7 where its rejection cannot destroy the other 9 cells).
interface iface_a(input bit clock);
  logic       ds;
  logic [7:0] din;
  logic [7:0] dout;
  logic       rdy;
  logic       reset;

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
    input  dout;
    input  rdy;
  endclocking

  modport IP(clocking cb, output reset, input clock);
endinterface

class drv_a;
  virtual iface_a.IP vif;
  logic [7:0] r;
  logic       b;

  function new(virtual iface_a.IP v);
    vif = v;
  endfunction

  task go();
    // c1  NONBLOCKING WRITE of a clocking OUTPUT var -- THE WITNESS SHAPE
    vif.cb.ds <= 1;
    // c2  NONBLOCKING WRITE, vector clockvar
    vif.cb.din <= 8'h5a;
    // c3  READ of a clocking INPUT var, plain assign rhs
    r = vif.cb.dout;
    // c4  READ inside a larger EXPRESSION
    r = vif.cb.dout + 8'h1;
    // c5  READ in a CONDITION
    if (vif.cb.rdy)
      r = 0;
    // c6  READ as a CALL ARGUMENT
    $display("%0d", vif.cb.dout);
    // c7  EVENT CONTROL on the CLOCKING BLOCK itself
    @(vif.cb);
    // c8  EVENT CONTROL on a clocking var
    @(vif.cb.rdy);
    // c9  NEGATIVE CONTROL: a NON-clocking interface member in an event control
    //     (this is SVSwitch Driver.sv:52's own shape) -- must stay 2-element
    @(posedge vif.clock);
    // c10 NEGATIVE CONTROL: a plain modport signal, written raw -- 2-element
    vif.reset <= 1;
    // c11 READ of a clockvar as an INDEX
    b = r[vif.cb.dout];
  endtask
endclass

module top_a;
  bit clock = 0;
  iface_a i_a(clock);
  drv_a d;
  initial begin
    d = new(i_a);
    d.go();
  end
endmodule
