// § pkgImpParamMemberColons210 — vp04 (v11u210 break probe): a PACKED ARRAY of structs parameter imported into a package, both imported into a module
package ap;
  typedef struct packed { logic [1:0] x; logic y; } in_t;
  parameter in_t [1:0] PA = '{ '{ x: 2'd2, y: 1'b0 }, '{ x: 2'd3, y: 1'b1 } };
endpackage
package bp;
  import ap::*;
  parameter logic [1:0] LB = 2'b01;
endpackage
module dut import ap::*; import bp::*; (output logic [1:0] o);
  assign o = LB;
endmodule
