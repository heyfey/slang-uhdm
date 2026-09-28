// § pkgArrTdElemClone209: an array typedef as a function formal and return
package pkg;
  typedef struct packed { logic [3:0] x; logic y; } a;
  typedef a [1:0] b;
  function automatic b swap(b v);
    b r;
    r[0] = v[1];
    r[1] = v[0];
    return r;
  endfunction
endpackage
module top (input pkg::b i, output logic [3:0] o);
  pkg::b c;
  assign c = pkg::swap(i);
  assign o = c[0].x;
endmodule
