// v149 arm 6 -- UNIONS: the union member loop got the same hook.  A TAGGED
// union may carry a queue; a packed union may not.  A struct that contains a
// union and a union that contains a struct are both here.
package Upsilon_pkg;
  typedef struct packed {
    logic [7:0] sp_hi;
    logic [7:0] sp_lo;
  } small_packed_t;

  typedef union tagged {
    void      Nothing;
    int       Counted;
  } tagged_u;

  typedef union packed {
    logic [15:0] up_all;
    small_packed_t up_split;
  } packed_u;

  typedef struct {
    packed_u  embeddedUnion;
    string    afterUnionQ[$];
    tagged_u  embeddedTagged;
  } holder_t;

  holder_t theHolder;
endpackage

module unions_top;
  import Upsilon_pkg::*;
  holder_t h5;
  initial h5.embeddedUnion.up_all = 16'h1234;
endmodule
