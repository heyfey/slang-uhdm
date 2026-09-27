// § newLhsBitSelAtIndex181 (v11u181 break: new into a queue element, an assoc element, a copy new, a parenthesized index, a member array in a class)
module top;
  class C; int x; function new(int a = 0); x = a; endfunction endclass
  class H;
    C m [4];
    function void mk(int i); m[i] = new(i); m[i+1] = new; endfunction
  endclass
  C q[$];
  C aa[int];
  C one [3];
  C h;
  int i;
  initial begin
    q[0] = new(3);
    aa[5] = new;
    h = new;
    one[i+1] = new h;
    one[(i)] = new;
  end
endmodule
