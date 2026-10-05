// § pkgImpPackedArrElemCopy240: a three-package chain: the struct in one package, the parameter in a second, re-listed by a third that exports
package sp;
  typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
  } s_t;
endpackage
package cp;
  import sp::*;
  localparam s_t [2:0] T = '{'{8'd1, 8'd2}, '{8'd3, 8'd4}, '{8'd5, 8'd6}};
endpackage
package bp;
  import cp::*;
  export cp::*;
  localparam int K = 2;
endpackage
module top
  import bp::*;
 (output logic [7:0] o);
  assign o = cp::T[K].b;
endmodule
