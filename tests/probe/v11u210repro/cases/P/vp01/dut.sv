// § pkgImpParamMemberColons210 — vp01 (v11u210 break probe): three package levels (cp imports bp imports ap) with a NESTED struct parameter; the module imports only the last package
package ap;
  typedef struct packed { logic [1:0] x; logic y; } in_t;
  typedef struct packed { in_t s; logic [3:0] c; } out_t;
  parameter out_t PO = '{ s: '{ x: 2'd1, y: 1'b1 }, c: 4'd5 };
endpackage
package bp;
  import ap::*;
  parameter logic [1:0] LB = 2'b01;
endpackage
package cp;
  import bp::*;
  parameter logic [1:0] LC = 2'b10;
endpackage
module dut import cp::*; (output logic [1:0] o);
  assign o = LC;
endmodule
