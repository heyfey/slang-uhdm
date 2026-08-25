// r10v87 arm va6 — a TYPEDEF'D package parameter (its typespec is a package
// typedef) and a parameter whose typespec RANGE names another parameter
// (earl85's stamped case) both colliding with overridden formals.
package pt6;
  typedef logic [7:0] byte_t;
  localparam int    VW = 5;
  localparam byte_t VA = 8'd91;
  localparam logic [VW-1:0] VR = 5'd9;
endpackage

module tleaf #(parameter int VW = 3,
               parameter pt6::byte_t VA = 8'd1,
               parameter logic [2:0] VR = 3'd2)
              (output logic [7:0] o);
  import pt6::*;
  assign o = VA + {5'd0, VR};
endmodule

module top87 (output logic [7:0] o1, o2);
  tleaf #(.VW(4), .VA(8'd7))  u_a (.o(o1));
  tleaf #(.VR(3'd5))          u_b (.o(o2));
endmodule
