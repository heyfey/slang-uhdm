// § clsPropWholeArrTd249
typedef int f_t[4];
class c;
  f_t m;
  rand f_t r;
  constraint k { foreach (r[i]) r[i] < 5; }
  function int sum(); int s = 0; foreach (m[i]) s += m[i]; return s + $size(m); endfunction
endclass
module top; c h; endmodule
