// § lvIdxThisPathIsRead312
class grid #(int W = 4); int i; int ia[W]; int r; function void probe(); ia[this.i] = r; endfunction endclass
module top; grid #(8) g; endmodule
