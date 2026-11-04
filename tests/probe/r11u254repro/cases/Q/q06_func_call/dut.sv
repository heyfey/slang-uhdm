// § pkgSelIdxRefColons254 (inside a function, as a call argument and inside an indexed part-select, a localparam and a header parameter)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (output logic [3:0] o, output logic [3:0] p);
  localparam int L = 2;
  function automatic logic [3:0] f(logic [3:0] x); return x; endfunction
  assign o = f(cp::RC[L][W-1:0]);
  assign p = cp::RC[1][L +: W];
endmodule
