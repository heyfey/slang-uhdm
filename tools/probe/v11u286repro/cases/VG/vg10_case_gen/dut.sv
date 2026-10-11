// § genProcLvIdxCallSpan286
module top #(parameter K = 2);
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  case (K)
    2: begin : c2
      always_comb v[fn(2)] = 1'b1;
    end
    default: begin : cd
      always_comb v[fn(0)] = 1'b0;
    end
  endcase
endmodule
