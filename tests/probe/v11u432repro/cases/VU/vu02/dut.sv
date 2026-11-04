// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  if (CF) begin : g
    assign o = a[0];
  end else begin : h
    assign o = a[1];
  end
endmodule
