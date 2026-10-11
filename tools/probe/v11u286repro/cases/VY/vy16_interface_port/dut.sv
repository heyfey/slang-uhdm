// § genProcLvIdxCallSpan286
interface ifc;
  logic [7:0] v;
endinterface
module sub (ifc p);
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb p.v[fn(1)] = 1'b1;
  end
endmodule
module top;
  ifc i();
  sub s(.p(i));
endmodule
