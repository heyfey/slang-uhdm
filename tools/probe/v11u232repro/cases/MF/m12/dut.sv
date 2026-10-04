// § caCallArgCastAbstains232v
// a judge-equal shape (one package function, the FA grid's package): a cast around the parameter, and a bare call beside it in another instance
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
endpackage
module sub #(parameter logic [0:2] M = 3'b001) (output int o);
  assign o = q::cnt(3'(M)) + 1;
endmodule
module sub2 #(parameter logic [0:2] M = 3'b001) (output int o);
  assign o = q::cnt(M);
endmodule
module top(output int o, output int p);
  sub #(.M(3'b101)) u (.o(o));
  sub2 #(.M(3'b110)) v (.o(p));
endmodule
