// § tpUseSigBindsTpObj291
interface ifc #(parameter type IT = int) ();
  IT a;
endinterface
module dut(output logic o);
  ifc #(.IT(logic [4:0])) i0 ();
  assign o = |i0.a;
endmodule
