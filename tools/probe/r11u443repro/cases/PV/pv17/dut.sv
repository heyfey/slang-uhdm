// § foreachPackedRefDeclTs443
class C; logic [3:0] p; function int f(); int s = 0; foreach (p[i]) s += p[i]; return s; endfunction endclass
module top; initial begin C c = new; $display(c.f()); end endmodule
