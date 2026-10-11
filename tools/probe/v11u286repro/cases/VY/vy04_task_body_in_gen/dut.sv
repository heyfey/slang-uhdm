// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  task automatic t(); v[fn(2)] = 1'b0; endtask
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial begin v[fn(1)] = 1'b1; t(); end
  end
endmodule
