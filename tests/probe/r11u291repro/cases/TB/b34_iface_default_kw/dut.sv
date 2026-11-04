// § tpUseSigBindsTpObj291
interface ifc #(parameter type IT = int) ();
  IT a;
endinterface
module dut(output logic o);
  ifc i0 ();
  assign o = |i0.a;
endmodule
