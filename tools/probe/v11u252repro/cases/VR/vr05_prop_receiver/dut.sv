// § cloneRandWithParentCall252
package p;
  class item; rand int x; rand int y; function int f(); return 1; endfunction endclass
  class lib;
    rand int z;
    item m_it;
    extern virtual task execute(item w);
  endclass
  task lib::execute(item w);
    item it;
    int v;
    it = w;
    void'(m_it.randomize() with { x[3:0] == 2; y == 1; });
    void'(this.m_it.randomize() with { x == 0; });
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
