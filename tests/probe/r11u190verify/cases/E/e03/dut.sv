// § enumImportParentLastWriter180 § enumImpDefOwner180v (r11u190: the wildcard import comes from one header included into two module bodies)
package p;
  typedef enum logic {OFF, ON} sw_e;
endpackage
module zeta;
`include "imp.svh"
  sw_e z;
endmodule
module alpha;
`include "imp.svh"
  sw_e a;
endmodule
module top;
  alpha ua();
  zeta uz();
endmodule
