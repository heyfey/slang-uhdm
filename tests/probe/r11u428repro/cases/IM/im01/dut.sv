// § modIfaceMethodImplLastNameless428
interface bus(input logic clk);
  logic [7:0] data;
  extern task T1();
  extern task T2(input logic [7:0] x);
  modport slave(export T1, export T2);
endinterface
module mm(interface a);
  task a.T1();
    a.data = 0;
  endtask
  task a.T2(input logic [7:0] x);
    a.data = x;
  endtask
endmodule
module top;
  logic clk;
  bus b(clk);
  mm u(b.slave);
endmodule
