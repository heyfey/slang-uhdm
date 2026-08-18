module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int sym(int n); return n; endfunction
  localparam int S = sym(P);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(S);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
