// r10v167 arm K - the MINIMAL isolation of the one AWAY shape: a shelled,
// RECEIVER-LESS, NAMED call that SKIPS a middle formal, to a COMPILATION-UNIT
// function, inside a DEF-view generate process (our linked4 == false).
function automatic int uk167(int a, int b = 0, int c = 0);
  return a + b + c;
endfunction
module mk167 #(parameter int P = 1) (output int o);
  generate
    if (P == 1) begin : klive
      always_comb o = 1;
    end
    else begin : kdead
      always_comb o = uk167(.a(nosuch167::val), .c(9));
    end
  endgenerate
endmodule
module tk167 (output int o1);
  mk167 #(.P(1)) k1 (.o(o1));
endmodule
