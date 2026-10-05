// § pkgImpPackedArrElemCopy240: two importing packages of one parameter, and a module instance two levels down reading it
package cp;
  typedef struct packed {
    logic [3:0] xd;
  } ps_t;
  parameter ps_t [1:0] allc = 8'h21;
endpackage
package bp;
  import cp::*;
  localparam int W1 = 1;
endpackage
package dp;
  import cp::*;
  localparam int W2 = 2;
endpackage
module leaf import cp::*; (output logic [3:0] o);
  assign o = allc[1].xd;
endmodule
module mid (output logic [3:0] o);
  leaf u_l(.o(o));
endmodule
module top
  import bp::*;
  import dp::*;
 (output logic [3:0] o);
  mid u_m(.o(o));
endmodule
