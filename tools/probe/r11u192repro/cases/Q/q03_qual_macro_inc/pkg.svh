package p;
  parameter int unsigned S = $clog2(16);
endpackage
`define PS p::S
`define SEL(v) v[p::S:0]
