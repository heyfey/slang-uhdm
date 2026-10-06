// § pkgSelIdxRefColons254 (inside a function return, a task output assignment and a struct-member read after the selects)
package sp;
  typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
  parameter s_t [1:0][1:0] SA = '0;
  parameter logic [1:0][3:0][7:0] R3 = '1;
endpackage
module top #(parameter int W = 1) (output logic [7:0] o, output logic [3:0] p, output logic [7:0] q);
  function automatic logic [7:0] rf(); return sp::R3[W][0]; endfunction
  task automatic tt(output logic [7:0] x); x = sp::R3[0][W]; endtask
  assign o = rf();
  assign p = sp::SA[W][0].f;
  always_comb tt(q);
endmodule
