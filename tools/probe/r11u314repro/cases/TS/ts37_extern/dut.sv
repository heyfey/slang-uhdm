// § lvIdxThisSelPathIsRead314
class grid; int ia[4]; int i; int r; extern function void probe(); endclass
function void grid::probe(); ia[this.ia[i]] = r; endfunction
module top; endmodule
