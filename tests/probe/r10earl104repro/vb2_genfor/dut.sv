// r10v104 vb2 -- MINIMAL: a generate-for loop BOUND reads the parameter.
module vb2_genfor(output logic o);
  m_gf u_gf (.o(o));
endmodule
module m_gf (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] oo;
  for (genvar i = 0; i < X[0]+1; i = i + 1) begin : gl
    assign oo[i] = 1'b0;
  end
  assign o = oo[0];
endmodule
