// v84x8 — DELIBERATE BREAKAGE ATTEMPTS: concat lvalue, $cast output, for-init/step
// lvalues, deep chain as a built-in ARGUMENT, super.new args, and a macro that
// supplies only PART of the chain.
`define ROOT84 this
`define TAIL84 h.fld
module v84x8;
  class in8x;
    int fld;
    int arr[$];
  endclass
  class b8x;
    function new(int x); endfunction
  endclass
  class c8x extends b8x;
    in8x h;
    in8x g;
    int  q[$];
    int  n;
    int  m;
    function new();
      super.new(1);
    endfunction
    function void f(int i);
      {this.h.fld, this.g.fld} = 2'b11;      // L23 CONCAT LVALUE
      {n, this.h.fld} = 2'b01;               // L24 mixed concat lvalue
      void'($cast(this.h.fld, i));           // L25 $cast OUTPUT actual
      for (this.h.fld = 0; this.h.fld < 3; this.h.fld++) n = 1;  // L26 init/cond/step
      this.q.push_back(this.h.fld);          // L27 deep chain as a builtin ARG
      this.q.delete(this.g.fld);             // L28 deep chain as a builtin ARG
      n = `ROOT84.h.fld;                     // L29 macro supplies the ROOT only
      n = this.`TAIL84;                      // L30 macro supplies the TAIL only
      n = this.h.arr[this.g.arr[i]];         // L31 nested deep chain in an index
      m = this.h.fld;                        // L32 plain control
    endfunction
  endclass
endmodule
