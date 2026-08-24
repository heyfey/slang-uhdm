// r10v78 arm v7 — PREEMPTION probe: replication Rhs shapes that LATER
// gen-scope arms in emitGenScopes would have handled (the never-written
// const-init module-var fold, the const-call fold, the unpacked-param select).
module v7;
  localparam int N = 4;
  logic [7:0] cv = 8'hA5;              // const-init module var, NEVER written
  localparam logic [7:0] UP [0:1] = '{8'h11, 8'h22};
  function automatic logic [3:0] f7();
    return 4'b1010;
  endfunction
  logic [31:0] p_var, p_call, p_sel, p_mix;
  logic [7:0]  p_cvw;
  if (N > 0) begin : g7
    assign p_var  = {4{cv}};        // P1 element a const-init module VAR
    assign p_cvw  = {1{cv}};        // P2 same, count 1
    assign p_call = {4{f7()}};      // P3 element a CONST-FUNCTION call
    assign p_sel  = {4{UP[1]}};     // P4 element an unpacked-array param select
    assign p_mix  = {4{cv[3:0]}};   // P5 element a part-select of that var
  end
endmodule
