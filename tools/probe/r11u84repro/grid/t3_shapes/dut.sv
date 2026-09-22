// r11u84 t3 - THE IMPORT-SHAPE GRID: diamond, duplicate items, a wildcard and
// an explicit item over the same home, the SLOT of an explicit item against
// the package's own declarations, and the negatives.  `importPackage` pushes
// into the scope's own vector AT THE IMPORT ITEM, and the home's vector
// ALREADY carries ITS clones (its own CompilePackage ran first), so
// transitivity needs no recursion in the producer.
package s1;
  wire  [7:0] s_net;
  logic [7:0] s_var = 8'd1;
  typedef logic [7:0] sw_t;
  wire sw_t   s_wtd;
endpackage

// DIAMOND: both arms reach s1.
package s2;  import s1::*;        logic [7:0] q2; endpackage
package s4;  import s1::*;        logic [7:0] q4; endpackage
package s5;  import s2::*; import s4::*;  logic [7:0] q5; endpackage

// DUPLICATE: the same explicit name twice; a wildcard PLUS the explicit item,
// in both orders.
package s6;  import s1::s_net; import s1::s_net;  logic [7:0] q6; endpackage
package s7;  import s1::*; import s1::s_net;      logic [7:0] q7; endpackage
package s8;  import s1::s_net; import s1::*;      logic [7:0] q8; endpackage

// ORDER: own declarations before and after the import items.
package sa;
  wire  [7:0] before_a;
  import s1::s_var;
  wire  [7:0] after_a;
  import s1::*;
  wire  [7:0] last_a;
endpackage

// NEGATIVES: a package nobody imports, and one that imports a package with
// NO data declarations at all.
package sz;  wire [7:0] z_net; endpackage
package sy;  parameter int YP = 1; typedef logic [1:0] y_t; endpackage
package sx;  import sy::*; wire [7:0] x_own; endpackage

module dut (output logic [31:0] o);
  import s5::*; import s6::*; import s7::*; import s8::*; import sa::*;
  import sx::*;
  assign o = {24'd0, q5 ^ q6 ^ q7 ^ q8 ^ before_a ^ x_own};
endmodule
