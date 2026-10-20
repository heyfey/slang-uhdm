// § externTaskCallUnlinked415
interface bus;
  int slaves;
  extern forkjoin task countSlaves(input int k);
  modport slave (ref slaves, export countSlaves);
  initial begin
    slaves = 0;
    countSlaves(2);
  end
endinterface
module mem (interface a);
  task a.countSlaves(input int k);
    a.slaves += k;
  endtask
endmodule
module top;
  bus sb();
  mem m1(sb.slave);
  mem m2(sb.slave);
endmodule
