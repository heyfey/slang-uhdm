// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [1:0]);
  T [1:0] d;
endinterface
module dut (input logic [3:0] a, output logic [3:0] o);
  ifc u ();
  assign u.d = a;
  assign o = u.d;
endmodule
