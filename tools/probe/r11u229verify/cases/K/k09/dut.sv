// § strLitContOwnerEnd224 (a package parameter's conditional default, read by a module)
package p;
  parameter string P = 1 ? "x" : "ab \
cd";
endpackage
module top(output string o);
  assign o = p::P;
endmodule
