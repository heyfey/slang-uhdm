// § pkgArrTdListing250
package p;
  typedef logic [7:0] b_t[4];
endpackage
module sub(input p::b_t i, output logic [7:0] o);
  assign o = i[0];
endmodule
module top(input p::b_t i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule
