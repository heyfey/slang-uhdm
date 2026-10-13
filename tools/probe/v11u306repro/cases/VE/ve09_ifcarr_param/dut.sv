// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; } t_t;
interface ifc; logic [7:0] sig; endinterface
module top(output logic [7:0] r);
  localparam t_t P = '{k: 4'd1};
  ifc ifs[4] ();
  assign r = ifs[P.k].sig;
endmodule
