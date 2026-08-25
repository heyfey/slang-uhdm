// r10v124 arm 2 — this./super./chained receivers.
package Foundry;
  typedef string Ribbon[$];

  class Anvil;
    Ribbon Sleeve[string];
    Ribbon Rows[4];
    function void base_fill(string kx);
      this.Sleeve[kx].push_back("aa");
      Sleeve[kx].push_back("bb");
      this.Rows[1].push_back("cc");
      this.Sleeve[kx].delete();
    endfunction
  endclass

  class Hammer extends Anvil;
    function void derived_fill(string kx);
      super.Sleeve[kx].push_back("dd");
      super.Rows[2].push_back("ee");
      this.Sleeve[kx].push_back("ff");
    endfunction
  endclass

  class Bracket;
    Anvil Limb;
    function void reach(string kx);
      Limb.Sleeve[kx].push_back("gg");
      Limb.Rows[3].push_back("hh");
    endfunction
  endclass

  class Girder;
    Bracket Wing[2];
    Bracket Solo;
    function void span(string kx);
      Wing[0].Limb.Sleeve[kx].push_back("ii");
      Wing[1].Limb.Rows[0].push_back("jj");
      Solo.Limb.Rows[1].push_back("kk");
    endfunction
  endclass
endpackage

module Forge;
  Foundry::Hammer hh;
  Foundry::Girder gg;
  initial begin
    hh = new(); gg = new();
    hh.derived_fill("nail");
    gg.span("bolt");
  end
endmodule
