// § newArrayCallArgStripped220
module top(output int o);
  class c;
    int d[];
    function int g(int a); return a; endfunction
    function void f(int n);
      d = new[g(n)];
    endfunction
  endclass
  c h;
  initial begin h = new; h.f(2); o = h.d.size(); end
endmodule
