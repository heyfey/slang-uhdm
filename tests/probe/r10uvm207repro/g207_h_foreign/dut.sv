// r10uvm207 arm H — IS THE MEMBER'S STRUCT ITSELF IMPORTED?  The second half of
// the grid question.  The struct typedef and its member typedef live in a THIRD
// package the importer does NOT import; the cloned body names them QUALIFIED.
// If golden bares the member alias here too, the law is about the CLONE BODY;
// if it does not, the law is about the IMPORTED typedef.
package p207c_x;
  typedef bit [63:0] bt207x;
  typedef struct { bt207x x_min207; bt207x x_max207; int x_stride207; } sx207;
endpackage

package p207a_x;
  typedef bit [31:0] bt207a;
  typedef struct { bt207a a_min207; int a_stride207; } sa207;
  function automatic int fx207();
    p207c_x::sx207 lx207;                 // FOREIGN, not imported by p207b_x
    sa207          lo207;                 // OWN, imported by p207b_x
    return int'(lx207.x_min207) + int'(lo207.a_min207);
  endfunction
endpackage

package p207b_x;
  import p207a_x::*;                      // imports p207a_x only
  function automatic int gb207x();
    return fx207();
  endfunction
endpackage

module g207_h_foreign;
  import p207b_x::*;
  int r207x;
  initial r207x = gb207x();
endmodule
