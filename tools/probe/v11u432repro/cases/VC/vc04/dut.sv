// § clsParamCallSymBind432v
function automatic int f(int a); return a; endfunction
class C;
  static function int f(int a); return a * 2; endfunction
  localparam M = f(3);
endclass
module test;
endmodule
