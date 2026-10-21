// § modIfaceMethodImplLastNameless428
interface bus(input logic clk);
  logic [7:0] data;
  extern function int F();
  modport slave(export F);
endinterface
module mm(interface a);
  function int a.F();
    return a.data;
  endfunction
endmodule
module top;
  logic clk;
  bus b(clk);
  mm u(b.slave);
endmodule
