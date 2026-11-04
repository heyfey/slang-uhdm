// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v, w;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb begin
      v[fn(1) +: 2] = 2'b11;
      w[fn(3):fn(1)] = 3'b101;
    end
  end
endmodule
