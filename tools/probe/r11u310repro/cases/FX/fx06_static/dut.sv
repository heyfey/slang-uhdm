// § methTailIdxNestShape310
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
class grid;
  static item sarr[4]; static holder sh; static int sr;
  static function void probe();
    sr = sarr[sh.k].get();
  endfunction
endclass
module top; endmodule
