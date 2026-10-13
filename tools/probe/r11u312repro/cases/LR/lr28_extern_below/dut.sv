// § lvRootSelCallNameSpan312
class item; int f; endclass
class grid; item iarr[4]; int i; int r; extern function int fn(int x); function void probe(); iarr[fn(i)].f = r; endfunction endclass
function int grid::fn(int x); return x; endfunction
module top; endmodule
