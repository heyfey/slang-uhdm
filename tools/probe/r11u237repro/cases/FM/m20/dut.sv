// § evalFuncPkgStructMemberFolds237
// r11v131's k03 with bit [3:0] members
package pk;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
  function automatic logic [3:0] g(); return pk::P.a; endfunction
endpackage
module top (output logic [3:0] o);
  assign o = pk::g();
endmodule
