// § parenCallCallee479
class C; rand int x; endclass
module top; C h; int r; initial begin h = new; r = (h.randomize()); end endmodule
