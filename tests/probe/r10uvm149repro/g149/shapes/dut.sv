// r10uvm149 arm D -- PACKED vs UNPACKED aggregates, a UNION control, a NESTED
// struct that itself carries a queue, and 1..3 instances of a leaf.
package Sigma_pkg;
  typedef struct packed {
    logic [7:0] pk_hi;
    logic [7:0] pk_lo;
  } packed_only_t;

  typedef struct {
    string   unp_q[$];
    packed_only_t unp_pk;
  } mixed_t;

  typedef union packed {
    logic [15:0] uni_all;
    packed_only_t uni_split;
  } uni_t;

  typedef struct {
    mixed_t  outerMixed;
    string   outerQ[$];
    int      outerPlain;
  } outer_t;
endpackage

module leaf_carrier;
  import Sigma_pkg::*;
  mixed_t m;
  uni_t   u;
  outer_t o;
  initial m.unp_pk.pk_hi = 8'h5;
endmodule

module shapes_top;
  leaf_carrier i_one();
  leaf_carrier i_two();
  leaf_carrier i_three();
endmodule
