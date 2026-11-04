// § tfPsBoundOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  function automatic logic [31:0] f1(input logic [31:0] a);
    return a[S:0];
  endfunction
  function automatic logic [31:0] f2(input logic [31:0] a);
    return a[S-1:0];
  endfunction
  function automatic logic [31:0] f3(input logic [31:0] a);
    return a[p::S:0];
  endfunction
  function automatic logic [31:0] f4(input logic [31:0] a);
    logic [31:0] r;
    r = '0;
    r[S:0] = a[31:S];
    return r;
  endfunction
  assign y1 = f1(x);
  assign y2 = f2(x);
  assign y3 = f3(x);
  assign y4 = f4(x);
endmodule
