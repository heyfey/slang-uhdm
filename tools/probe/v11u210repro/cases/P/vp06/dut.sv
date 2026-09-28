// § pkgImpParamMemberColons210 — vp06 (v11u210 break probe): the importing package READS the imported struct parameter in its own parameter and function, a union-typed parameter beside it
package ap;
  typedef struct packed { logic a; logic [2:0] b; } st_t;
  typedef union packed { logic [3:0] u; st_t s; } un_t;
  parameter st_t PS = '{ a: 1'b1, b: 3'd2 };
  parameter un_t PU = 4'b1010;
endpackage
package bp;
  import ap::*;
  parameter logic [2:0] LB = PS.b;
  function automatic logic [3:0] f();
    return PU.u;
  endfunction
endpackage
module dut import bp::*; (output logic [2:0] o, output logic [3:0] p);
  assign o = LB;
  assign p = f();
endmodule
