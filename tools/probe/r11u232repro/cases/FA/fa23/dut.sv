// § caCallArgParamFormalTs232
module sub #(parameter logic [2:0] M = '0) (output int o);
  function automatic int unsigned cnt(logic [0:2] cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  assign o = cnt(M);
endmodule
module top(output int o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
