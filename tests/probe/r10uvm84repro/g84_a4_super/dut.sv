// r10uvm84 arm a4 — `super`-rooted twin: does the mockup hardcode "this"?
module g84a4;
  class b4;
    string q[$];
    int    n;
  endclass
  class c4 extends b4;
    function void f();
      n = super.q.size();
      if (super.q.size() > 0) n = 1;
    endfunction
  endclass
endmodule
