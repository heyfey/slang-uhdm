// r10uvm149 arm E -- NEGATIVE CONTROL: aggregates with NO unpacked dimension
// anywhere.  Both our databases must be BYTE-IDENTICAL pristine vs patched.
package Theta_pkg;
  typedef struct packed {
    logic [3:0] n_a;
    logic [3:0] n_b;
  } neg_packed_t;
  typedef struct {
    string n_s;
    int    n_i;
    neg_packed_t n_p;
  } neg_unpacked_t;
  typedef union packed {
    logic [7:0] u_all;
    neg_packed_t u_split;
  } neg_union_t;
endpackage

module neg_top;
  import Theta_pkg::*;
  neg_unpacked_t nu;
  neg_union_t    nun;
  initial nu.n_i = 3;
endmodule
