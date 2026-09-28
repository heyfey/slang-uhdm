// § pkgImpParamMemberColons210 — vp02 (v11u210 break probe): EXPLICIT single-name imports of a struct parameter and a vector-typedef parameter into a package, the module importing only that package
package ap;
  typedef struct packed { logic a; logic [2:0] b; } st_t;
  typedef logic [3:0] v_t;
  parameter st_t PS = '{ a: 1'b1, b: 3'd2 };
  parameter v_t PV = 4'd7;
endpackage
package bp;
  import ap::PS;
  import ap::PV;
  parameter logic [1:0] LB = 2'b01;
endpackage
module dut import bp::*; (output logic [1:0] o);
  assign o = LB;
endmodule
