// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[4] ();
  task automatic drive(virtual SBus b);
    b.req = 1;
  endtask
  initial drive(s[2]);
endmodule
