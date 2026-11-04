// § externTaskCallUnlinked415
interface bus (input logic clk);
  int slaves = 0;
  extern forkjoin task countSlaves();
  modport slave (input clk, ref slaves, export countSlaves);
  initial begin
    slaves = 0;
    countSlaves;
  end
endinterface
module mem (interface a);
  task a.countSlaves();
    a.slaves++;
  endtask
endmodule
module top;
  logic clk = 0;
  bus sb(clk);
  mem m1(sb.slave);
endmodule
