// § externTaskCallUnlinked415
interface bus (input logic clk);
  logic [7:0] d;
  extern task Write(input logic [7:0] w);
  modport slave (input clk, output d, export Write);
  initial Write(8'h5);
endinterface
module mem (interface a);
  task a.Write(input logic [7:0] w);
    a.d = w;
  endtask
endmodule
module top;
  logic clk = 0;
  bus sb(clk);
  mem m1(sb.slave);
endmodule
