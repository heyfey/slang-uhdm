// v149 arm 8 -- NEGATIVE CONTROL, different shapes from the implementer's:
// no unpacked dimension anywhere, packed arrays only.  Both OUR databases
// must be BYTE-IDENTICAL pristine vs patched.
package Xi_pkg;
  typedef logic [3:0][7:0] packed2d_t;
  typedef struct packed {
    packed2d_t np_grid;
    logic      np_flag;
  } np_packed_t;
  typedef struct {
    np_packed_t np_inner;
    string      np_name;
    real        np_val;
  } np_outer_t;
endpackage

module neg2_top;
  import Xi_pkg::*;
  np_outer_t nn;
  initial nn.np_val = 1.5;
endmodule
