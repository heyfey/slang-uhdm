// § procPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z, output logic [31:0] q);
  always_comb begin
    {>>{y[W:0]}} = x[W:0];
    y[31:W+1] = '0;
  end
  always_comb begin
    z = x;
    z[W:0]++;
  end
  always_comb begin
    q = x;
    q[W:0] = {<<{x[W:0]}};
  end
endmodule
