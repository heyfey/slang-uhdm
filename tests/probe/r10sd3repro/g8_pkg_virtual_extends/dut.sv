// g8 — the UVM inheritance shape: a base class with a virtual in-body method
// and a derived class overriding it and calling super, both in one package.
package p8;
  class b8;
    virtual function bit do_cmp(string kind);
      do_cmp = (kind == "HARD");
    endfunction
  endclass
  class d8 extends b8;
    string nm;
    virtual function bit do_cmp(string kind);
      string loc;
      do_cmp = super.do_cmp(kind);
      loc = nm;
      if (loc == kind) do_cmp = 0;
    endfunction
  endclass
endpackage
module top8;
  import p8::*;
  d8 h;
  initial h = new();
endmodule
