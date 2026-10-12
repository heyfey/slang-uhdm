// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] zz;
  subq u_e [X[0]:0] ();
  assign o = zz[0];
endmodule
