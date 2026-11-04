// § genProcLvIdxCallSpan286
interface ifc;
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v[fn(1)] = 1'b1;
  end
endinterface
module top;
  ifc i();
endmodule
