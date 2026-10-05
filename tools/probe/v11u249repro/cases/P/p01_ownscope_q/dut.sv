// § clsPropWholeArrTd249
class c;
  typedef int q_t[$];
  q_t m;
  function void f(); m.push_back(1); endfunction
endclass
module top; c h; initial begin h = new; h.f(); end endmodule
