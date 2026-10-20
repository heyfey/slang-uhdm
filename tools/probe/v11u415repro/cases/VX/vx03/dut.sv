// § externTaskCallUnlinked415
interface bus;
  int v;
  extern task Write(input int d);
  modport slave (export Write);
  modport master (import Write);
endinterface
module mem (bus.slave a);
  task a.Write(input int d);
    a.v = d;
  endtask
endmodule
module cpu (bus.master b);
  initial b.Write(7);
endmodule
module top;
  bus sb();
  mem m1(sb.slave);
  cpu c1(sb.master);
endmodule
