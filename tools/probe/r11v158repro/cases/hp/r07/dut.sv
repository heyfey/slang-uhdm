// § thisPathFormByPosition157
class c; int x; int aa[4];
  function void f(int s);
    ++this.x; this.x--; this.x += 2; this.aa[s]++; --this.aa[s];
    if (this.x > 0) this.x = this.aa[s];
  endfunction
endclass
module top; c o; initial begin o = new; o.f(1); end endmodule
