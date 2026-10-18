// § sizeCastSubrLocalParam401
package p;
  function automatic int clip(int width);
    return (width > 0) ? width : 1;
  endfunction
endpackage
module top import p::*; #(parameter int UPW = 1) (input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(logic [3:0] c);
    localparam int VW = clip($clog2(UPW + 1));
    logic [VW-1:0] v;
    v = VW'(0);
    v = v + VW'(1);
    return c + 4'(v);
  endfunction
  assign o = f(i);
endmodule
