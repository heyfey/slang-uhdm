// § pkgArrTdElemClone209: an array-of-struct typedef as a class property and an interface signal
package pkg;
  typedef struct packed { logic [3:0] x; logic y; } a;
  typedef a [1:0] b;
  class c;
    b v;
    function logic [3:0] get(); return v[1].x; endfunction
  endclass
endpackage
interface bif;
  pkg::b d;
endinterface
module top(output logic [3:0] o);
  bif i();
  assign i.d = '0;
  assign o = i.d[0].x;
endmodule
