// § externTaskCallUnlinked415
interface bus;
  int v;
  extern function int f(int x);
  modport slave (export f);
  initial v = f(1);
endinterface
module mem (bus.slave a);
  function int a.f(int x);
    return x + 1;
  endfunction
endmodule
module top;
  bus sb();
  mem m1(sb.slave);
endmodule
