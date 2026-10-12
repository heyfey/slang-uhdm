// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic signed [3:0]);
  T d;
endinterface
module dut (input logic signed [3:0] a, output logic signed [3:0] o);
  ifc u ();
  ifc #(.T(logic signed [4:0])) u2 ();
  assign u.d = a;
  assign u2.d = a;
  assign o = u.d + u2.d;
endmodule
