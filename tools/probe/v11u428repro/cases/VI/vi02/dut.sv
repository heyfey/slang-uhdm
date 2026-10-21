// § modIfaceMethodImplLastNameless428
interface bus;
  logic [7:0] data;
  extern task T1();
  extern function int F();
  modport slave(export T1, export F);
endinterface
module mm(bus.slave a);
  function int a.F();
    return 3;
  endfunction
  task a.T1();
    a.data = 1;
  endtask
endmodule
module top;
  bus b();
  mm u(b);
endmodule
