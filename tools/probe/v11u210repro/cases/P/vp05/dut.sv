// § pkgImpParamAliasColons210 — vp05 (v11u210 break probe): an ENUM-typed and a SIGNED vector-typedef parameter imported into a package, the module importing only that package
package ap;
  typedef enum logic [1:0] { EA, EB, EC } e_t;
  typedef logic signed [5:0] sv_t;
  parameter e_t PE = EB;
  parameter sv_t PS = -6'sd3;
endpackage
package bp;
  import ap::*;
  parameter logic [1:0] LB = 2'b01;
endpackage
module dut import bp::*; (output logic [1:0] o);
  assign o = LB;
endmodule
