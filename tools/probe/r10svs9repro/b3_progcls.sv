// r10svs9 arm b3 — the successor head, localized further.  b1/b2 refuted
// "program scope", "instantiated", "has ports" and "interface-modport port" as
// the discriminator: all of those already carry the
// `ref_typespec -> class_typespec` on our side.  SVSwitch's two live sites are
// `Environment env;` (a class holding VIRTUAL INTERFACES, one of them an ARRAY)
// and `small_packet spkt;` (a DERIVED class), so this arm varies the CLASS.
interface in_if(input bit clock);
  logic reset;
  clocking cb @(posedge clock);
  endclocking
  modport IP(clocking cb, output reset, input clock);
endinterface

class base_pkt;
  rand int data;
endclass

// o1 a DERIVED class (SVSwitch `small_packet extends packet`).
class small_pkt extends base_pkt;
  constraint small_c { data > 200; }
endclass

// o2 a class holding a virtual interface AND AN ARRAY of virtual interfaces
//    (SVSwitch `Environment`), plus a mailbox, plus a handle to another class.
class Env;
  virtual in_if.IP  vif;
  virtual in_if.IP  varr[4];
  mailbox           mb;
  small_pkt         sp;
  function void build_stub(); endfunction
  function new(virtual in_if.IP v, virtual in_if.IP va[4]);
    this.vif  = v;
    this.varr = va;
  endfunction
endclass

program tc(in_if.IP ip);
  Env       env;      // o2 site
  small_pkt spkt;     // o1 site
  initial begin
    spkt = new();
    env.build_stub();
  end
endprogram

module top;
  bit clk = 0;
  in_if u_i(clk);
  tc TC(u_i.IP);
endmodule
