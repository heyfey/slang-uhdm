// r10uvm84 arm a5 — the member is INDEXED before the method (`this.q[i].len()`).
module g84a5;
  class c5;
    string q[$];
    int    n;
    function void f(int i);
      n = this.q[i].len();
      n = this.q[i+1].len();
    endfunction
  endclass
endmodule
