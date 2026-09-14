interface ifc;
  logic [31:0] iv;
  assign iv = '0;
endinterface
module top(output logic [31:0] o2);
  ifc u();
  assign o2 = u.iv;
endmodule
