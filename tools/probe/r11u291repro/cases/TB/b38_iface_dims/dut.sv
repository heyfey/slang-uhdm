// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [1:0]);
  T [2:0] d;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = ^u.d;
endmodule
