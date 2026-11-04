// § trailIdxVarSelNamesByPath278
module sub(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign o = q.f[m[1][2]];
endmodule
module top(output logic o1, output logic o2, input logic [1:0][3:0] m);
  sub a(o1, m);
  sub b(o2, m);
endmodule
