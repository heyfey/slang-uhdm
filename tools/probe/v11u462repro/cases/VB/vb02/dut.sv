// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
  typedef enum bit [1:0] {M0, M1} f_t;
endpackage
package b;
  import a::*;
  e_t bv;
endpackage
module top;
  import b::*;
  logic x;
endmodule
