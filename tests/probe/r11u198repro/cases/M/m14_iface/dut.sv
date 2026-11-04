// § methodArgOpRefChainName198
interface ifc; function automatic int f(int k); return k; endfunction endinterface
module top (input int a, output int y);
  ifc bus();
  function automatic int g(int i);
    return bus.f(i + 1);
  endfunction
  assign y = g(a);
endmodule
