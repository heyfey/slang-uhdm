// § methodArgOpRefChainName198: a program function and a module-scope initial block (no subroutine: control) calling a method with an operation argument
class C; function int f(int k); return k; endfunction endclass
program pg;
  C c;
  function automatic int pf(int i);
    return c.f(i * 2 + 1);
  endfunction
endprogram
module top;
  C c;
  int k, x;
  initial x = c.f(k + 1);
endmodule
