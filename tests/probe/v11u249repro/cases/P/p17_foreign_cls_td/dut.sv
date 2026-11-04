// § clsPropWholeArrTd249 (control: the law does not fire)
class a; typedef int f_t[2]; endclass
class b; a::f_t m; endclass
module top; b h; endmodule
