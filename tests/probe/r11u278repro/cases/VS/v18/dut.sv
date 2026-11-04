// § trailIdxVarSelNamesByPath278
module leaf(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[m[1][2]];
endmodule
module mid(output logic o, input logic [1:0][3:0] m); leaf l(.o(o), .m(m)); endmodule
module top(output logic o, input logic [1:0][3:0] m); mid u(.o(o), .m(m)); endmodule
