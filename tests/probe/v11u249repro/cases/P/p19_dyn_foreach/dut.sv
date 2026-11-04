// § clsPropWholeArrTd249
typedef byte d_t[];
typedef int q_t[$];
class c;
  d_t d; q_t q;
  function void f(); d = new[3]; foreach (d[i]) q.push_back(d[i]); q.delete(); endfunction
endclass
module top; c h; endmodule
