// § timeModVarIsNet406
class C;
  time t;
endclass
module top;
  C c;
  time u;
  initial begin c = new; c.t = 1; u = c.t; end
endmodule
