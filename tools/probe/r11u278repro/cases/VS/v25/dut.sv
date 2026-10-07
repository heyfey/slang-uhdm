// § trailIdxVarSelNamesByPath278
interface ifc;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [1:0][3:0] m; logic o;
  always_comb o = q.f[m[1][2]];
endinterface
module top; ifc u(); endmodule
