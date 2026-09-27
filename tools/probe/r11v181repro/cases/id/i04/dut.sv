// § incDecMixedPathIsLvalue181 § classMethodLvIsProcess181 (v11u181 break: inc/dec in a class method through this, a local handle, and a member struct array)
typedef struct { int v; } s_t;
class K;
  s_t arr[4];
  K nx;
  function void f(int i);
    this.arr[i].v++;
    nx.arr[i+1].v--;
    arr[i].v += 2;
  endfunction
endclass
module top; initial begin K k = new; k.f(0); end endmodule
