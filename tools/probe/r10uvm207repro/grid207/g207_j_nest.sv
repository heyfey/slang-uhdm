// r10uvm207 arm J — THE NESTED STRUCT and THE STRUCT INSIDE AN ARRAY INSIDE A
// STRUCT.  The law's clone-copy walk recurses through a member whose own type
// is a struct; this arm is the guard that the recursion is measured against a
// real golden rather than assumed.
package p207a_j;
  typedef bit [63:0] bt207j;
  typedef struct { bt207j j_in207; int j_pad207; } sin207;
  typedef struct { sin207 j_nest207; bt207j j_top207; } sout207;
  typedef struct { sin207 j_arr207[]; bt207j j_o207; } sarr207;
  function automatic int fj207();
    sout207 lo207;
    sarr207 la207;
    return int'(lo207.j_nest207.j_in207) + int'(lo207.j_top207)
         + int'(la207.j_o207);
  endfunction
endpackage

package p207b_j;
  import p207a_j::*;
  function automatic int gb207j();
    return fj207();
  endfunction
endpackage

module g207_j_nest;
  import p207b_j::*;
  int r207j;
  initial r207j = gb207j();
endmodule
