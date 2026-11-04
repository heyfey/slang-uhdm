// § forMultiInitAssign258 (a class handle's property as the first initializer in a module initial)
class c; int x; endclass
module top(output int o);
  c h; int i;
  initial begin h = new; o = 0; for (h.x = 0, i = 0; h.x < 2; h.x++) o++; end
endmodule
