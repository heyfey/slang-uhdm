// § genericPlainNamedView176 § genericMpConnLowConnAtDecl176
interface PI #(parameter int W = 2);
  logic [W-1:0] drive;
  wire [W-1:0] bus;
  logic [W-1:0] observe;
  modport tb (output drive, input observe);
endinterface
module M (interface intf);
  initial intf.drive = '1;
endmodule
module TOP();
  PI #(.W(8)) c8();
  PI #(.W(3)) c3();
  M u8(.intf(c8));
  M u3(.intf(c3.tb));
endmodule
