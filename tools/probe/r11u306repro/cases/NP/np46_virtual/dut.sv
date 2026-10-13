// § nonTrailIdxPathNestShape306
class item; int f; endclass
class holder; int k; endclass
virtual class base;
  pure virtual function void probe();
endclass
class grid extends base;
  item iarr[4]; int r; holder h;
  virtual function void probe(); r = iarr[h.k].f; endfunction
endclass
module top; endmodule
