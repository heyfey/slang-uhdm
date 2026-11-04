// § clsArrPropConcatInitElemSize430
class C; int a[4] = {1, 2, 3, 4}; function int f(); return a[2]; endfunction endclass
module top; C c; int x; initial begin c = new; x = c.f(); end endmodule
