// § ifaceConnNetAfterForwarded452
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule
