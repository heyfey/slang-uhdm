// r10uvm146 arm D — MULTIPLICITY and INSTANCES: one package imported TWICE at
// $unit scope in the same file, a second package imported once, and a module
// instantiated three times (the listing is a DESIGN listing, so instance count
// must not change it).
package twice_pk;
  parameter T_x = 6;
  parameter t_y = 7;
endpackage

package once_pk;
  parameter O_z = 8;
endpackage

import twice_pk::*;
import once_pk::*;
import twice_pk::*;

module d_leaf #(parameter LP = 0) (output int lo);
  assign lo = T_x + t_y + O_z + LP;
endmodule

module d_multi(output int s);
  int a, b, c;
  d_leaf #(.LP(1)) i1(a);
  d_leaf #(.LP(2)) i2(b);
  d_leaf #(.LP(3)) i3(c);
  assign s = a + b + c;
endmodule
