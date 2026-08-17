// r10uvm84 arm d2 — CONSTRAINT / randomize-with contexts vs the ordinary
// expression twin on the next line.
module g84d2;
  class in2d;
    int fld;
  endclass
  class c2d;
    in2d h;
    rand int r;
    int  n;
    constraint cst { this.r < this.h.fld; }
    function void f();
      void'(this.randomize() with { r < this.h.fld; });
      if (this.h.fld > 0) n = 1;
    endfunction
  endclass
endmodule
