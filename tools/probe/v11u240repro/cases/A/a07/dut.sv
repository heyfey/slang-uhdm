// § pkgImpPackedArrElemCopy240: controls: a struct parameter (no array), an unpacked array of the struct, and a typedef local to the importing package
package cp;
  typedef struct packed {
    logic [3:0] xd;
  } ps_t;
  parameter ps_t one = 4'h3;
  parameter ps_t unp [2] = '{4'h1, 4'h2};
endpackage
package bp;
  import cp::*;
  typedef struct packed {
    logic [3:0] zz;
  } loc_t;
  parameter loc_t [1:0] lp = 8'h11;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [3:0] o);
  assign o = one.xd ^ lp[0].zz;
endmodule
