// § nonTrailIdxPathNestShape306
class item; rand int f; endclass
class holder; int k; endclass
class grid;
  rand item iarr[4]; holder h;
  constraint c { iarr[h.k].f > 0; }
endclass
module top; endmodule
