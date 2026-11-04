// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class cdb #(type T = int); static function bit set(string n, T v); return 1; endfunction endclass
module top; logic clk; ifc u(clk); bit b;
  initial b = cdb#(virtual ifc)::set("vif", u);
endmodule
