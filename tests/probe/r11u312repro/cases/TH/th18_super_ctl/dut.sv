// § lvIdxThisPathIsRead312
class base; int i; endclass
class grid extends base; int ia[4]; int r; function void probe(); ia[super.i] = r; endfunction endclass
module top; endmodule
