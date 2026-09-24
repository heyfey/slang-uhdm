// r10uvm84 arm a1 — `this.<member>.<method>()` in EVERY EXPRESSION context.
module g84a1;
  class c1;
    string q[$];
    int    n;
    function void f_for();
      for (int i = 0; i < this.q.size(); i++) n = i;      // the CORPUS shape
    endfunction
    function void f_if();
      if (this.q.size() > 0) n = 1;
    endfunction
    function void f_assign();
      n = this.q.size();
    endfunction
    function void f_arith();
      n = this.q.size() - 1;
    endfunction
    function int f_return();
      return this.q.size();
    endfunction
    function void f_arg();
      $display("%0d", this.q.size());
    endfunction
    function void f_while();
      while (this.q.size() != 0) this.q.delete(0);
    endfunction
    function void f_case();
      case (this.q.size())
        0: n = 0;
        default: n = 9;
      endcase
    endfunction
  endclass
endmodule
