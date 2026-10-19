// § unitFwdCallNoLink403
class C;
  function int g(int a); return f(a) + 1; endfunction
endclass
function int f(int y); return y + 1; endfunction
module top; C c = new; endmodule
