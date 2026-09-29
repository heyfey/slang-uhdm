// § hpVarSelRangeIdxNamesByPath220
module top #(parameter int SEL = 1) (input logic [32:0] din, input logic [1:0] i, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s = din;
  case (SEL)
    0: begin : c0 assign o = s.arr[i][1:0]; end
    default: begin : cd assign o = s.arr[i][3:2]; end
  endcase
endmodule
