// § genericPlainNamedView176
interface PI #(parameter int W = 2);
  logic [W-1:0] drive;
  wire [W-1:0] bus;
  logic [W-1:0] observe;
endinterface
module M (interface a, interface b);
  assign a.drive = b.observe;
endmodule
module TOP();
  PI #(.W(5)) c5();
  PI c2();
  M u(.b(c5), .a(c2));
endmodule
