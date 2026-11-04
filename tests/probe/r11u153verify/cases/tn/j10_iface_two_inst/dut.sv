// § tpDefaultCaIfaceKeeps146v
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T a, b;
  assign b = a;
endinterface
module dut(output logic o);
  ifc i1();
  ifc #(.W(8)) i2();
  assign o = i1.b[0] ^ i2.b[0];
endmodule
