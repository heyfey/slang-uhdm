// § newArrayCallArgStripped220
module top(output int o);
  int d[];
  int n = 3;
  function automatic int f(int a); return a + 1; endfunction
  initial begin
    d = new[f(n)];
    o = d.size();
  end
endmodule
