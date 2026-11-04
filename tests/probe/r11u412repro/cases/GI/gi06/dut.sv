// § genericIfacePosConnNoDouble412
interface sb;
  logic req;
endinterface
module mm(interface a);
  logic av;
  always @* av = a.req;
endmodule
module top;
  sb s();
  mm u(s);
endmodule
