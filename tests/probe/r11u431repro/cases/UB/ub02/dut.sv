// § unitParamNameBindsDesign431
localparam CF = 0, VF = 1;
module top(input [3:0] c, input [1:0] op, output logic y);
always_comb
  case (op)
    2'd0: y = c[CF];
    default: y = c[VF];
  endcase
endmodule
