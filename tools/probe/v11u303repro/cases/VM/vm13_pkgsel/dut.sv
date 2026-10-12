// § modArrBoundSelUnstored303
package pk; localparam logic [7:0] X = 8'd6; endpackage
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  subq u_e [pk::X[2:1]:0] ();
  assign o = 1'b0;
endmodule
