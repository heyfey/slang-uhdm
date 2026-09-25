// § tpDefaultCaIfaceKeeps146v
interface ifc #(parameter int W = 4, parameter type T = logic [W-1:0]);
  T a, b;
  assign b = a;
endinterface
module m(ifc p, output logic o);
  assign o = p.b[0];
endmodule
module dut(output logic o);
  ifc i();
  m u(.p(i), .o(o));
endmodule
