// § thisPathFormByPosition157
class c;
  int x; int y;
  function void f();
    this.x |= 3;
    this.x <<= 1;
    this.x ^= this.y;
    y = this.x++;
    if (this.x inside {1, 2}) y = 0;
  endfunction
endclass
module top; c o; initial begin o = new; o.f(); end endmodule
