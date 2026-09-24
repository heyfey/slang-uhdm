// r10uvm84 arm a3 — the SAME calls written WITHOUT `this` (control).
module g84a3;
  class c3;
    string q[$];
    int    n;
    function void f();
      n = q.size();
      if (q.size() > 0) n = 1;
      for (int i = 0; i < q.size(); i++) n = i;
    endfunction
  endclass
endmodule
