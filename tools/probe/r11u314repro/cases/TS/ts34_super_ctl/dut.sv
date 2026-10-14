// § lvIdxThisSelPathIsRead314
class base; int ia[4]; endclass
class grid extends base; int i; int r; function void probe(); ia[super.ia[i]] = r; endfunction endclass
module top; endmodule
