// § forMultiInitAssign258 (two initializers, the first an interface member)
interface bif; int v; endinterface
module m(bif bi); int i; logic [7:0] y;
  always_comb begin
    for (bi.v = 0, i = 0; i < 4; i++) y = i;
  end
endmodule
module top; bif b(); m u(.bi(b)); endmodule
