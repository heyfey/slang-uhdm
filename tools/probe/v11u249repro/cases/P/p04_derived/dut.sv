// § clsPropWholeArrTd249
typedef byte b_t[4];
class base; b_t m; endclass
class der extends base; b_t n; function void f(); m[0] = n[1]; endfunction endclass
module top; der h; endmodule
