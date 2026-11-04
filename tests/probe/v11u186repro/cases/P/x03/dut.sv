// § pkgParamElabCaSharesDefFold183 (a qualified read, two modules, nested hierarchy)
package p;
   localparam logic [3:0] X = 4'd9;
endpackage
module leaf(output logic [3:0] a);
   assign a = p::X;
endmodule
module mid(output logic [3:0] a, output logic [3:0] b);
   leaf l(.a(a));
   assign b = p::X;
endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
   mid m(.a(o1), .b(o2));
endmodule
