// § formalDefaultNamedThroughFormal191: a module function default of a unary and a $bits over a formal, an interface function default
interface ifc;
  function automatic int g(int a, int b = -a);
    return a + b;
  endfunction
endinterface
module top(output int o, output int q);
  function automatic int f(logic [3:0] a, int b = $bits(a) * 2);
    return a + b;
  endfunction
  ifc u();
  assign o = f(4'h1);
  assign q = u.g(3);
endmodule
