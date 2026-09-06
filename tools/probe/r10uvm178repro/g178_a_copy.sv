// r10uvm178 ARM A — THE COPY DIMENSION.  MEASUREMENT ONLY.
// The same package-parameter read, reachable through FOUR copy populations:
//   * the home package's OWN listing (which the design writes twice, as
//     AllPackages and as TopPackages -> the def/elab COPIES);
//   * ONE wildcard-import clone of that listing (Crc_one);
//   * THREE wildcard-import clones (Kalpha / kBeta / K3), whose names, case and
//     numbering deliberately DIFFER from one another so that an arm cannot
//     agree by being self-confirming.
// The reference is the uvm site's own shape: `crc ^= <param>` in a free
// package function.

package HomeCrc178;
  parameter CRC_SEED_178 = 32'h04c11db6;
  function automatic int unsigned home_hash178(input int unsigned c);
    int unsigned crc;
    crc = c;
    crc ^= CRC_SEED_178;
    return crc;
  endfunction
endpackage

package Crc_one;
  import HomeCrc178::*;
  function automatic int unsigned one_hash178(input int unsigned c);
    int unsigned q;
    q = c;
    q ^= CRC_SEED_178;
    return q;
  endfunction
endpackage

package Kalpha;
  import HomeCrc178::*;
  function automatic int unsigned alpha_hash(input int unsigned v);
    int unsigned w;
    w = v;
    w ^= CRC_SEED_178;
    return w;
  endfunction
endpackage

package kBeta;
  import HomeCrc178::*;
  function automatic int unsigned beta_hash(input int unsigned v);
    return v ^ CRC_SEED_178;
  endfunction
endpackage

package K3;
  import HomeCrc178::*;
  function automatic int unsigned k3_hash(input int unsigned v);
    int unsigned z;
    z = v;
    z ^= CRC_SEED_178;
    return z;
  endfunction
endpackage

module m178a (input logic clk, output int unsigned oh, o1, oa, ob, o3);
  import HomeCrc178::*;
  import Crc_one::*;
  import Kalpha::*;
  import kBeta::*;
  import K3::*;
  assign oh = home_hash178(32'd11);
  assign o1 = one_hash178(32'd22);
  assign oa = alpha_hash(32'd33);
  assign ob = beta_hash(32'd44);
  assign o3 = k3_hash(32'd55);
endmodule
