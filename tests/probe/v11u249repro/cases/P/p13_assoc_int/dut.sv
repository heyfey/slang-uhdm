// § clsPropWholeArrTd249
typedef logic [3:0] a_t[int];
class c; a_t m; function void f(); m[3] = 1; endfunction endclass
module top; c h; endmodule
