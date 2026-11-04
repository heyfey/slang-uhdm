// § unitParamShadowDefBind432
localparam N = 1;
module m(input [3:0] a, output [3:0] o);
  localparam N = 4;
  for (genvar i = 0; i < N; i++) begin : g
    assign o[i] = a[i];
  end
endmodule
