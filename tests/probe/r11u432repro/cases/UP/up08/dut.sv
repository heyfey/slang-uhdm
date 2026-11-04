// § unitParamShadowDefBind432
localparam CF = 0, VF = 1;
module m(input [3:0] a, output logic o);
  localparam CF = 1, VF = 2;
  always_comb begin
    case (a[1:0])
      2'd0: o = a[CF];
      default: o = a[VF];
    endcase
  end
endmodule
