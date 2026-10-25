// § clsParamCallSymBind432v
function automatic int f(int a); return a; endfunction
function automatic int h(int a); return a + 2; endfunction
class C #(int N = 1);
  static function int f(int a); return a * 2; endfunction
  localparam M = h(f(N));
  localparam K = h(N) + 1;
endclass
module test;
  C #(3) c;
endmodule
