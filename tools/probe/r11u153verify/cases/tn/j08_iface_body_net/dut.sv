// § tpDefaultCaIfaceKeeps146v
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T a;
  wire T b;
  assign b = a;
endinterface
module dut(output logic o);
  ifc i();
  assign o = i.b[0];
endmodule
