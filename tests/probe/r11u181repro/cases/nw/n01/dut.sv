// § newLhsBitSelAtIndex181 — a class-handle array element assigned a new object in a class method (SVSwitch's rcvr[i] = new(...))
class R; int a; function new(int x); a = x; endfunction endclass
class E;
  R rcvr [4];
  function void build();
    foreach (rcvr[i])
      rcvr[i] = new(i);
  endfunction
endclass
module top; initial begin E e = new; e.build(); end endmodule
