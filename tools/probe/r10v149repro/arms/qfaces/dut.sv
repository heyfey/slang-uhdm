// v149 arm 1 -- QUEUE ELEMENT FACES the implementer's grid does not carry:
// a parameterized-width vector, an int-based enum, a deep nested struct, a
// class handle, a BOUNDED queue of a byte, a 2-D fixed control, a packed
// vector element, and a plain scalar control.  Names are deliberately not
// parallel with the implementer's.
package Rho_pkg;
  parameter int WIDE = 12;
  typedef logic [WIDE-1:0] param_vec_t;
  typedef enum int { ALPHA = 7, BETA = 9 } mood_e;
  typedef struct { int deep_x; string deep_y; } deep_t;
  class Holder;
    int held;
  endclass
  typedef struct {
    param_vec_t   pvQ[$];
    mood_e        moodQ[$];
    deep_t        deepQ[$];
    Holder        holdQ[$];
    byte          byteQ[$:3];
    int           twoD[2][3];
    logic [7:0]   mixQ[$];
    bit           lonely;
    string        trailing[$];
  } faces_t;
  faces_t oneOfThem;
endpackage

module qfaces_top;
  import Rho_pkg::*;
  faces_t f7;
  initial f7.lonely = 1'b1;
endmodule
