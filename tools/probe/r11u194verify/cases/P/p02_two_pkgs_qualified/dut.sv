// § pkgParamElabCaSharesDefFold183: parameters of two packages read by qualified name and by import in one module's continuous assignments, the module instanced twice
package pa;
  parameter int A = 3;
endpackage
package pb;
  parameter logic [3:0] B = 4'd9;
endpackage
module m (output int a, output logic [3:0] b);
  import pb::B;
  assign a = pa::A;
  assign b = B;
endmodule
module top (output int o1, output int o2, output logic [3:0] q1, output logic [3:0] q2);
  m u1 (.a(o1), .b(q1));
  m u2 (.a(o2), .b(q2));
endmodule
