// § genProcParamFold — does the gen-scope process fold reach a TF-CALL
// ARGUMENT?  One module parameter (W) in six positions of one gen-scope
// process: bare Rhs, binary operand, part-select bound, function-call argument
// (bare and inside an expression), task-call argument.
module top #(parameter W = 32) (output logic [7:0] o);
    logic [63:0] wide;

    function automatic int fn(input int x);
        return x + 1;
    endfunction

    task automatic tk(input int y);
        wide[7:0] = y[7:0];
    endtask

    genvar gi;
    generate
        for (gi = 0; gi < 1; gi++) begin : g
            logic [7:0] r;
            int q;
            always @(*) begin
                r = W;                  // bare Rhs
                r = W + 1;              // binary operand
                r = wide[W-1 -: 8];     // part-select bound
                q = fn(W);              // function-call argument, bare
                q = fn(W / 8);          // function-call argument, expression
                tk(W);                  // task-call argument
            end
        end
    endgenerate
    assign o = g[0].r;
endmodule
