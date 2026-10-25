// § clsParamCallSymBind432v
function automatic int f(int a); return a; endfunction
class B;
  static function int f(int a); return a * 3; endfunction
endclass
class C extends B;
  localparam M = f(3);
endclass
module test;
endmodule
