// v6_neg102 -- the MUST-STAY half: an associative dimension, a queue, a
// dynamic array, the PACKED twin of the law's bound, arrays vars and nets, and
// a typedef'd unpacked-array element type.
package v6p102;
  parameter int N = 4;
  typedef int arr_t [0:N-1];                    // typedef carrying the same bound
  parameter arr_t TDARR = '{default:0};         // package param of that typedef
  parameter logic [N-1:0] PACKED_TWIN = '0;     // the PACKED spelling -- must stay
  parameter int NEST [0:N-1] = '{default:0};
endpackage

module v6sub102;
  import v6p102::*;
  int  assoc_v [string];
  int  q_v [$];
  int  dyn_v [];
  logic [N-1:0] pk;
  wire  [N-1:0] wn;
  int   av [0:N-1];
  wire  an [0:N-1];
  int t = TDARR[0] + NEST[0] + int'(PACKED_TWIN) + av[0];
endmodule

module v6_neg102;
  v6sub102 u_a();
endmodule
