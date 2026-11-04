// § tfPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y [2], output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    function automatic logic [31:0] f(logic [31:0] a); return a[W:0]; endfunction
    assign y[i] = f(x);
  end
  task automatic t(input logic [31:0] a, output logic [31:0] b); b = {a[31:W], 1'b0}; endtask
  always_comb t(x, z);
endmodule
