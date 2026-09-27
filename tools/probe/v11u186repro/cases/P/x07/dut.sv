// § pkgParamElabCaSharesDefFold183 (two different modules, each instanced twice, read one package parameter)
package p;
   parameter logic [5:0] X = 6'o17;
endpackage
module m1(output logic [5:0] a); import p::X; assign a = X; endmodule
module m2(output logic [5:0] a); import p::*; assign a = X; endmodule
module top(output logic [5:0] o1, o2, o3, o4);
   m1 a1(.a(o1));
   m2 b1(.a(o2));
   m1 a2(.a(o3));
   m2 b2(.a(o4));
endmodule
