// § modIfaceMethodImplLastNameless428
interface bus;
  logic [7:0] data;
  extern task T1();
  modport slave(export T1);
endinterface
module mm(bus.slave a);
  task a.T1();
    a.data = 1;
  endtask
endmodule
module top;
  bus b();
  mm u(b);
  initial b.T1();
endmodule
