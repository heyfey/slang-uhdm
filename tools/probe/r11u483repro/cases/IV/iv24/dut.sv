// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class cdb #(type T = int); static function void set(string n, T v); endfunction endclass
module top; logic clk; ifc u(clk);
  initial cdb#(virtual ifc)::set("vif", u);
endmodule
