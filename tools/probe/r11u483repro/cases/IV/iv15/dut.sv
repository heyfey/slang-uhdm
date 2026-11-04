// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class C; static virtual ifc v; static function void set(virtual ifc x); v = x; endfunction endclass
module top; logic clk; ifc u(clk);
  initial C::set(u);
endmodule
