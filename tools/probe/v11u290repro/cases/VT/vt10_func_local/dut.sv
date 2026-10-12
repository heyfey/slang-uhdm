// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top(output logic [3:0] o);
p::t [1:0] x;
function automatic logic [3:0] f();
  p::t [6:0] v;
  v = '0;
  return v[1:0];
endfunction
assign o = f();
endmodule
