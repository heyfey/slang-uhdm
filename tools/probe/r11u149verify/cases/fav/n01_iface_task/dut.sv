// § foreachArrayPlaceholderFile140
interface ifc;
  int q[$];
  task automatic clr();
    foreach (q[i]) q[i] = 0;
  endtask
endinterface
module dut;
  ifc u();
endmodule
