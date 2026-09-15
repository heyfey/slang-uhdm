// v6_dims35 — THE AGGREGATE'S OWN DIMENSION, and a member that is itself an
// aggregate array: does the law's flag leak onto bounds it does not own?
package p6v35;
  localparam int PW = 20;
endpackage

module v6_dims35 #(parameter int W = 8, parameter int N = 4)
                  (input logic clk, output logic o);
  // the aggregate default carries its OWN trailing packed dimension
  localparam type dim_t = struct packed {
    logic [W-1:0] a;
  } [N-1:0];
  dim_t dv;

  // a member that is a packed array of a named typedef
  typedef logic [p6v35::PW-1:0] w6_t;
  localparam type arr_t = struct packed {
    w6_t [N-1:0]  m;
    logic [W-1:0] b;
  };
  arr_t av;

  always_comb o = dv[0][0] ^ av.b[0];
endmodule
