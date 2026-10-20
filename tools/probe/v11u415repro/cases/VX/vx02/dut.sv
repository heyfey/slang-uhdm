// § externTaskCallUnlinked415
interface bus;
  int v;
  extern task Write(input int d);
  modport slave (export Write);
  task kick();
    Write(5);
  endtask
  initial kick();
endinterface
module mem (bus.slave a);
  task a.Write(input int d);
    a.v = d;
  endtask
endmodule
module top;
  bus sb();
  mem m1(sb.slave);
endmodule
