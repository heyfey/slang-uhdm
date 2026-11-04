// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
class grid; static item iarr[4]; static int ia[4]; static function void probe(int i); ia[iarr[i].get()] = 1; endfunction endclass
module top; endmodule
