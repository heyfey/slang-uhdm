// § ovrMultiDimConstUnparented131
// case o05: a parameter typed by a package 2-D packed typedef, overridden
package pk;
  typedef logic [1:0][3:0] t2;
endpackage
module sub #(parameter pk::t2 M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module top(output logic [7:0] o);
  sub #(.M(8'h69)) u(.o(o));
endmodule
