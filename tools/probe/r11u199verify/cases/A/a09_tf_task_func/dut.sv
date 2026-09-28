// § tfPsBoundOwner192 § procPsBoundOwner192
package p;
  parameter int unsigned W = 5;
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  function automatic logic [31:0] f(input logic [31:0] a);
    logic [31:0] t;
    t = '0;
    t[W:0] = a[W:0];
    return {t[31:W], a[W-1:0]};
  endfunction
  task automatic tk(input logic [31:0] a, output logic [31:0] b);
    b = a[W:1];
    b[31:W] = '1;
  endtask
  assign y1 = f(x);
  always_comb tk(x, y2);
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2);
  sub u (.*);
endmodule
