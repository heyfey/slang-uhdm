// § modIfaceMethodImplLastNameless428
interface bus;
  logic [7:0] data;
  extern task T1();
  modport slave(export T1);
endinterface
module mm(bus.slave a);
  task automatic a.T1();
    a.data = 1;
  endtask
endmodule
module top;
  bus b1(), b2();
  mm u1(b1);
  mm u2(b2);
endmodule
