// § newLhsBitSelAtIndex181 — class-handle array elements assigned new in a class method: arguments, no arguments, an operation index, a constant index
class R; int a; function new(int x = 0); a = x; endfunction endclass
class E;
  R rs [4];
  function void build(int k);
    rs[k] = new(k);
    rs[k+1] = new;
    rs[2] = new(3);
  endfunction
endclass
module top; initial begin E e = new; e.build(1); end endmodule
