// § nonTrailIdxPathNestShape306
class item; int f; endclass
class holder; int k; endclass
class grid #(int N = 4);
  item iarr[N]; int r; holder h;
  function void probe(); r = iarr[h.k].f; endfunction
endclass
module top;
  grid #(2) g2;
  initial begin g2 = new; g2.probe(); end
endmodule
