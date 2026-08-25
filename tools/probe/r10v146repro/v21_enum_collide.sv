// A package ENUM MEMBER with the same name as the $unit-imported parameter.
package pv21a;
  parameter int STATE = 80;
endpackage
package pv21b;
  typedef enum int { STATE = 8, OTHER = 9 } st_e;
  function automatic int fb(); return STATE + OTHER; endfunction
endpackage
import pv21a::*;
module top_v21;
  int z;
  initial z = pv21b::fb() + STATE;
endmodule
