// § ppStrEndNotTokStart251 (the produced end crosses a continuation line onto a call on the next body line)
`define D(F) \
  s = `"F`"; \
  g(y);
module top;
  string s; int y;
  function void g(int a); endfunction
  initial begin `D(abcdefghi) end
endmodule
