// § pkgSelPsBoundColonsElab260 (a function declared inside an if-generate block)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (input logic [7:0] d, output logic [7:0] q);
  if (W > 4) begin : g
    function automatic logic [7:0] f(logic [7:0] x);
      logic [7:0] r;
      r = x;
      r ^= cp::RC[1][W-1:0];
      return r;
    endfunction
    assign q = f(d);
  end else begin : h
    assign q = d;
  end
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
