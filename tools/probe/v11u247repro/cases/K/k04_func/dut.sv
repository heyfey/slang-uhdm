// § anonAggElemKeywordTs247
typedef bit [3:0] nb_t [2];
package p;
  typedef byte unsigned pb_t [2];
  typedef bit [3:0] qb_t [2];
  function automatic bit [3:0] psum(qb_t x);
    return x[0] ^ x[1];
  endfunction
endpackage
module top(input logic [3:0] a, output logic [3:0] o);
  import p::*;
  function automatic bit [3:0] sum(nb_t x);
    return x[0] ^ x[1];
  endfunction
  nb_t v;
  pb_t w;
  qb_t y;
  assign v[0] = a;
  assign v[1] = 4'h5;
  assign y[0] = a; assign y[1] = ~a;
  assign w[0] = {a, a};
  assign w[1] = 0;
  assign o = sum(v) ^ w[0][3:0] ^ psum(y);
endmodule
