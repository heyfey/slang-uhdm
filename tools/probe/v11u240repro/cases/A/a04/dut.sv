// § pkgImpPackedArrElemCopy240: an array typedef of the struct, a packed union element, and a parameter used as a replication count
package cp;
  typedef struct packed {
    logic [1:0] xd;
    logic [1:0] yd;
  } ps_t;
  typedef ps_t [3:0] arr_t;
  typedef union packed {
    logic [3:0] raw;
    ps_t p;
  } u_t;
  parameter arr_t allc = 16'h1234;
  parameter u_t [1:0] uall = 8'h5a;
endpackage
package bp;
  import cp::*;
  localparam int R = allc[1].xd + 1;
endpackage
module top
  import cp::*;
  import bp::*;
 (output logic [7:0] o);
  assign o = {R{uall[0].p.yd}};
endmodule
