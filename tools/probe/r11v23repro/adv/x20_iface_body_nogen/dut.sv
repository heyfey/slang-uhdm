interface ifc;
  logic [31:0] lv;
  assign lv = 1'b1 ? '0 : '1;
endinterface
module dut(input logic a, output logic o);
  ifc i0(); assign o = a;
endmodule
