// § pkgQualCaReadValueForm475 (residue: ModuleEmit emitContAssigns stamp)
package a;
  parameter int P = 33;
endpackage
module top(output logic [31:0] y);
  assign y = a::P;
endmodule
