// v115_c — a MODULE instantiated INSIDE a generate block.  In the ELABORATED
// listing the instance's parent chain runs through a gen_scope, but the
// module's own initial/task body is compiled in Surelog's MODULE pass, not
// during elaboration.  inGenScopeChain115 walks the WHOLE chain.
module mc_leaf;
  initial begin
    process lc_p;                     // module-in-generate initial local
    lc_p = process::self();
  end
  task automatic lc_tk();
    process lc_tp;
  endtask
endmodule

module mc_top;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : gblk
      mc_leaf u_leaf();
    end
  endgenerate
  initial begin
    process tc_p;                     // plain top-level control cell
    tc_p = process::self();
  end
endmodule
