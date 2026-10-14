// § lvIdxThisSelPathIsRead314
class grid #(int W = 4); int ia[W]; int i; int r; function void probe(); ia[this.ia[i]] = r; endfunction endclass
module top; grid #(8) g; endmodule
