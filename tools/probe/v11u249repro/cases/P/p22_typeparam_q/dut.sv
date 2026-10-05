// § clsPropWholeArrTd249
typedef byte q_t[$];
class c #(type T = q_t);
  T m;
  function void f(); m.push_back(1); endfunction
endclass
module top; c h; c #(q_t) g; endmodule
