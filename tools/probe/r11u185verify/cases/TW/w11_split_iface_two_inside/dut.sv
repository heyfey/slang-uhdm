// § tfArgDefTopSplit176
package p;
  typedef enum logic [2:0] {S0, S1, S2, S3} st_e;
  function automatic int f1(st_e a); return int'(a); endfunction
  function automatic int f2(input st_e b); return int'(b) + 1; endfunction
endpackage
interface ifc;
  import p::*;
  function automatic int g(st_e c); return int'(c) * 2; endfunction
endinterface
module top;
  ifc u();
  int r;
  initial r = u.g(p::S2) + p::f1(p::S1) + p::f2(p::S3);
endmodule
