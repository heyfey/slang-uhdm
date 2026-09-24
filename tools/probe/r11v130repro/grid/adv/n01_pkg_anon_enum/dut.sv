// § defNetEndOnlyLoc130
package p;
  enum logic [1:0] {PA, PB} pv;
endpackage
module top(output logic [1:0] o);
  assign o = p::pv;
endmodule
