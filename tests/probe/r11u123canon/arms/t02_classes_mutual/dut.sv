typedef class cb;
class ca;
  cb peer;
  int x;
  function void link(cb p); peer = p; p.peer = this; endfunction
endclass
class cb;
  ca peer;
  int y;
endclass
module top;
  ca a;
  cb b;
  initial begin a = new; b = new; a.link(b); end
endmodule
