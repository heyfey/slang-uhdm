`define NEGONE -1
`define NEGARG(x) -x
package pv30h;
  parameter int PDEF = -1;
  localparam int LPX = -2;
  typedef enum int { HE0 = -1, HE1 = 1 } he_t;
  typedef logic [1:-1] rng_t;
  class cv30h;
    int m;
    extern function int h_macro();
    extern function int h_macroarg();
    extern function int h_param();
  endclass
  function int cv30h::h_macro();    return (m == `NEGONE);     endfunction
  function int cv30h::h_macroarg(); return (m == `NEGARG(1));  endfunction
  function int cv30h::h_param();    return (m == -PDEF);       endfunction
endpackage

module mv30h #(parameter int P = -1) (output wire signed [7:0] o);
  import pv30h::*;
  localparam int Q = -3;
  int m;
  assign o = -1;
  always_comb begin
    case (m)
      -1: m = 0;
      default: m = 1;
    endcase
  end
  initial $display("%0d", -1);
endmodule

module mv30h_top;
  mv30h #(.P(-5)) u0 (.o());
  mv30h #(.P(-6)) u1 (.o());
endmodule
