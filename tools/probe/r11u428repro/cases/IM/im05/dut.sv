// § modIfaceMethodImplLastNameless428
interface bus(input logic clk);
  logic [7:0] data;
  extern task T1();
  modport slave(export T1);
endinterface
module mm(interface a);
  task t0(); endtask
  task a.T1();
    a.data = 0;
  endtask
endmodule
module top;
  logic clk;
  bus b(clk);
  mm u(b.slave);
endmodule
