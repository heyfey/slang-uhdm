// § elabCloneFullNameUnstored137
interface bus;
  logic d;
  task automatic drive(input logic v);
    d = v;
  endtask
  modport m(output d, import drive);
endinterface
module dut(bus.m b);
  initial b.drive(1'b1);
endmodule
module top();
  bus bb();
  dut u(.b(bb));
endmodule
