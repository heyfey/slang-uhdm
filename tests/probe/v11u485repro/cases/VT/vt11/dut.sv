// § implicitNetDefaultType485
`default_nettype tri1
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  task t(input virtual ifc x); endtask
  initial t(u);
endmodule
`default_nettype wire
