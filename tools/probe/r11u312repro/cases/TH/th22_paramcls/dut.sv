// § lvIdxThisPathIsRead312
class pc #(int N = 1); int ia[4]; int i; function void probe(); ia[this.i + N] = 1; endfunction endclass
module top; pc #(2) x; initial x = new; endmodule
