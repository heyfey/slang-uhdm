// r10svs5 ARM 2 — THE HANDLE grid: every way the clocking block can be reached
// that is NOT a virtual interface in a class, plus MULTIPLE clocking blocks and
// the two negative controls (a modport WITHOUT clocking, and a raw signal on the
// same interface instance).
interface iface_b(input bit clock);
  logic       ds;
  logic [7:0] din;
  logic [7:0] dout;

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
    input  dout;
  endclocking

  // d2/d5: a SECOND clocking block over the SAME signals, different edge.
  clocking cb2@(negedge clock);
    output ds;
    output din;
    input  dout;
  endclocking

  modport IP(clocking cb, clocking cb2, input clock);
  // NEGATIVE CONTROL: a modport with NO clocking at all.
  modport RAW(output ds, input dout, input clock);
endinterface

// d1/d2: the interface arrives as a MODULE PORT with a modport qualifier.
module sub_b(iface_b.IP p);
  initial begin
    p.cb.ds  <= 1;
    p.cb2.ds <= 1;
  end
endmodule

// d3: NEGATIVE CONTROL -- a modport port with no clocking block in it.
module sub_raw(iface_b.RAW q);
  initial q.ds <= 1;
endmodule

// d8: the interface arrives as a plain (un-modported) interface port.
module sub_plain(iface_b w);
  initial w.cb.din <= 8'h3;
endmodule

module mid_b(iface_b.IP m);
  sub_b u_in(m);
endmodule

module top_b;
  bit clock = 0;
  iface_b i_b(clock);
  sub_b     u_sub(i_b);
  sub_raw   u_raw(i_b);
  sub_plain u_pln(i_b);
  mid_b     u_mid(i_b);
  logic [7:0] r;
  initial begin
    // d4: a plain interface INSTANCE at module scope
    i_b.cb.ds <= 1;
    // d5: the second clocking block, vector clockvar
    i_b.cb2.din <= 8'h1;
    // d6: NEGATIVE CONTROL -- the SAME signal written RAW on the same instance
    i_b.ds <= 1;
    // d7: event control on the clocking block through an instance
    @(i_b.cb);
    // d9: a clocking INPUT read through an instance (rvalue)
    r = i_b.cb.dout;
    // d10: DEEP hierarchy -- through a module instance's interface PORT
    u_mid.m.cb.ds <= 1;
    // d11: DEEP hierarchy -- a plain NON-clocking modport member the same way
    //      (control; `ds` is not in modport IP so it cannot be used here)
    r = u_mid.m.clock;
  end
endmodule
