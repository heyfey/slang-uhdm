// § clsPropWholeArrTd249
typedef logic [7:0] f_t[2];
class base; virtual function void f(); endfunction endclass
class c extends base;
  f_t m;
  function void f(); m[0] = 8'h1; endfunction
endclass
module top; c h; initial begin h = new; h.f(); end endmodule
