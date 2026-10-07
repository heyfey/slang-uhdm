// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  function automatic logic f1(); return q.f[m[1][2]]; endfunction
  assign o = f1();
endmodule
