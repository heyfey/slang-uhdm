// A file-scope import of a package with NO classes at all.
package pi206;
  typedef enum { E206_A, E206_B } e206_t;
  typedef struct packed { logic [3:0] f; } s206_t;
  typedef logic [7:0] v206_t;
endpackage

import pi206::*;

module tg206;
  e206_t e;
  s206_t s;
  v206_t v;
  initial v = 0;
endmodule
