// § pkgImpPackedArrElemCopy240: a class in the importing package reads the parameter, a function returns a member
package cp;
  typedef struct packed {
    logic [3:0] xd;
  } ps_t;
  parameter ps_t [1:0] allc = 8'h21;
endpackage
package bp;
  import cp::*;
  function automatic logic [3:0] fx(int i);
    return allc[i].xd;
  endfunction
  class c;
    int v = allc[0].xd;
  endclass
endpackage
module top
  import bp::*;
 (output logic [3:0] o);
  assign o = fx(1);
endmodule
