// § genProcLvIdxCallSpan286 — case-generate initial block
module dut ();
  parameter int P = 2;
  logic [7:0] w;
  function automatic int fn(input int x); return x + 1; endfunction
  case (P)
    2: begin : gc
      initial w[fn(P)] = 1'b1;
    end
    default: begin : gd
      initial w[fn(0)] = 1'b0;
    end
  endcase
endmodule
