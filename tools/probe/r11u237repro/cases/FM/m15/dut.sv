// § evalFuncPkgStructMemberFolds237
// r11v131's k03 with int unsigned members
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } s_t;
  parameter s_t P = '{a: 1, b: 2};
  function automatic logic [3:0] g(); return pk::P.a; endfunction
endpackage
module top (output logic [3:0] o);
  assign o = pk::g();
endmodule
