// § pkgSelIdxRefColons254 (fresh: a package-qualified select in a localparam initializer, a class specialization value, a parameter default and a function call argument: none is an assignment right side)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
class k #(int V = 0); endclass
module top #(parameter int W = 4, parameter logic [3:0] D = cp::RC[0][W-1:0]) (output logic [3:0] o);
  localparam logic [3:0] L = cp::RC[1][W-1:0];
  k #(cp::RC[2][W-1:0]) h;
  function automatic logic [3:0] f(logic [3:0] x); return x; endfunction
  assign o = f(cp::RC[3][W-1:0]) ^ L ^ D;
endmodule
