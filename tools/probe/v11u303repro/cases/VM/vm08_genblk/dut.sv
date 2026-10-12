// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  localparam logic [7:0] X = 8'b0000_0101;
  for (genvar i = 0; i < 2; i++) begin : g
    subq u_e [X[i]:0] ();
  end
  assign o = 1'b0;
endmodule
