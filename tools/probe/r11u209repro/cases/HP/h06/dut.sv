// § pkgArrTdElemClone209
package q;
  typedef struct packed {
    logic y;
    logic z;
  } s_t;
  typedef s_t [3:0] v_t;
endpackage
module top(input clk, output logic o);
  import q::*;
  v_t w;
  always_ff @(posedge clk) begin
    w[0].z <= 1'b1;
    o <= w[0].z;
  end
endmodule
