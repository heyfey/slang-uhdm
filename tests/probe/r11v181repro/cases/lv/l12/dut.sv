// § newLhsBitSelAtIndex181 (v11u181 break: new into a class member array with a parenthesized, call, operation and member-read index; a queue member; a nonblocking-free copy new)
class R; int a; function new(int x = 0); a = x; endfunction endclass
class E;
  R rcvr [4];
  R q [$];
  R h;
  int k;
  function int ix(int x); return x; endfunction
  function void build();
    rcvr[(k)] = new(1);
    rcvr[ix(k)] = new;
    rcvr[k*2-1] = new(k);
    q[k] = new;
    h = new(2);
    rcvr[k+1] = new h;
  endfunction
endclass
module top; initial begin E e = new; e.build(); end endmodule
