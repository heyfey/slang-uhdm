// § trailIdxVarSelNamesByPath278
module top #(parameter int S = 1) (output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  case (S)
    1: begin : c1 always_comb o = q.f[m[1][2]]; end
    default: begin : c0 assign o = 1'b0; end
  endcase
endmodule
