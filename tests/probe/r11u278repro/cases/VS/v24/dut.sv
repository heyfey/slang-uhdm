// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  task automatic t1(output logic r); r = q.f[m[1][2]]; endtask
  always_comb t1(o);
endmodule
