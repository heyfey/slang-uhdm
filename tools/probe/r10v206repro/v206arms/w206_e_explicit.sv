// EXPLICIT import of a class whose representative is a CLASS-SCOPE typedef.
package pe2206;
  class ke206;
    typedef ke206 this_type;
    int n;
  endclass
endpackage

import pe2206::ke206;

module we206;
  ke206 h;
endmodule
