// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
class C; int s; function void f(); s = 1; endfunction endclass
initial foreach (v[i]) s = s + i;
endmodule
