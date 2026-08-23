// v115_f — GENERATE-SCOPE subroutines/forks at DEPTH, and a nested generate.
module mf_top;
  genvar gi, gj;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : og
      for (gj = 0; gj < 2; gj = gj + 1) begin : ig    // NESTED generate
        initial begin
          process ng_p;            // nested-generate initial local
          ng_p = process::self();
        end
        task automatic ng_tk();
          process ng_tp;           // nested-generate TASK local
        endtask
        initial begin
          fork
            begin : ng_f
              process nf_p;        // FORK inside a nested generate
              nf_p = process::self();
            end
          join_none
        end
      end
      if (1) begin : ifb           // if-generate inside a for-generate
        initial begin
          process if_p;
          if_p = process::self();
        end
      end
    end
  endgenerate
  initial begin
    process ctl_p;                 // the CONTROL cell outside every generate
    ctl_p = process::self();
  end
endmodule
