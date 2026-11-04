// § newArrayCallArgStripped220
module top;
  class c;
    function int g(int a); return a; endfunction
    function void f(int n);
      int d[];
      d = new[g(n)];
    endfunction
  endclass
endmodule
