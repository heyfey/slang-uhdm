// § ifcProcCallArgNoTs424
interface ifc(input bit clk);
  logic [3:0] y;
  task automatic t(input logic [3:0] a); $display(a); endtask
  initial t(y);
  initial t(4'h1);
endinterface
module top; bit c; ifc d(.clk(c)); endmodule
