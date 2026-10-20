// § externTaskCallUnlinked415
interface bus;
  int v;
  extern task Write(input int d, input int e);
  modport slave (export Write);
  initial Write(.e(2), .d(1));
endinterface
module mem (bus.slave a);
  task a.Write(input int d, input int e);
    a.v = d + e;
  endtask
endmodule
module top;
  bus sb();
  mem m1(sb.slave);
endmodule
