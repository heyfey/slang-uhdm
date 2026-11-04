// § newLhsBitSelAtIndex181 — break hunt: a two-dimensional handle array, a this-rooted element, a queue element and a member-path element assigned new in a class method
class R; int a; endclass
class H; R arr [2]; endclass
class E;
  R rs2 [2][2];
  R rs [4];
  R q [$];
  H h;
  function void build(int k);
    rs2[k][k+1] = new;
    this.rs[k] = new;
    q.push_back(null);
    q[0] = new;
    h = new;
    h.arr[k] = new;
  endfunction
endclass
module top; initial begin E e = new; e.build(1); end endmodule
