// r10vbuvm33 v33a.sv — TARGET TYPES and the ESCAPE's neighbours.
// A scoped foreach over: a packed vector, a based enum, a base-less enum,
// a packed struct, a packed union, a byte vector, a typedef'd array, a queue
// of class handles, an assoc array keyed by string and by int, a 2-D unpacked
// array with a SKIPPED dimension.  MEASUREMENT ONLY.
package pa33v;
  typedef enum { E0, E1, E2 } be33;            // base-less enum
  typedef enum bit [2:0] { F0, F1 } fe33;      // based enum
  typedef struct packed { bit [3:0] a; bit [3:0] b; } ps33;
  typedef union packed { bit [7:0] u; ps33 v; } pu33;
  typedef int ta33[4];

  class tc33;
    static logic [7:0]  vec33;
    static byte         bvec33 [5];
    static be33         benum33 [3];
    static fe33         fenum33 [3];
    static ps33         pstr33 [2];
    static pu33         puni33 [2];
    static ta33         tdar33;
    static tc33         hq33 [$];
    static int          as33 [string];
    static int          ai33 [int];
    static int          m2_33 [3][4];
  endclass
endpackage

module top33v;
  import pa33v::*;
  int sink33;
  logic [7:0] mvec33;
  int mm2_33 [3][4];
  initial begin
    foreach (tc33::vec33[i])    sink33 = i;   // V1  packed vector
    foreach (tc33::bvec33[i])   sink33 = i;   // V2  byte unpacked
    foreach (tc33::benum33[i])  sink33 = i;   // V3  base-less enum elems
    foreach (tc33::fenum33[i])  sink33 = i;   // V4  based enum elems
    foreach (tc33::pstr33[i])   sink33 = i;   // V5  packed struct elems
    foreach (tc33::puni33[i])   sink33 = i;   // V6  packed union elems
    foreach (tc33::tdar33[i])   sink33 = i;   // V7  typedef'd array
    foreach (tc33::hq33[i])     sink33 = i;   // V8  queue of class handles
    foreach (tc33::as33[k])     sink33 = 1;   // V9  assoc string
    foreach (tc33::ai33[k])     sink33 = k;   // V10 assoc int
    foreach (tc33::m2_33[i,j])  sink33 = i+j; // V11 two dims
    foreach (tc33::m2_33[,j])   sink33 = j;   // V12 SKIPPED first dim
    foreach (tc33::m2_33[i,])   sink33 = i;   // V13 SKIPPED second dim
    foreach (mvec33[i])         sink33 = i;   // V14 bare control (vector)
    foreach (mm2_33[i,j])       sink33 = i+j; // V15 bare control (2-D)
  end
endmodule
