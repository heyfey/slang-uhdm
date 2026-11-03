// § clsPropSpecFullNameLazy470 (a class property specialization only)
class res #(type T = int); T v; endclass
class C; res#(byte) pr; endclass
module top; C c; endmodule
