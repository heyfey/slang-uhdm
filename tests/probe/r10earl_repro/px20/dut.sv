// px20.sv — PASS 20: the genvar_loop_decl_3 regression, bisected by copying
// the test's own `gold` module verbatim (px_a) and then removing ONE feature
// per copy.  pw20's hand-built approximations of the same shape all bound in
// golden, so the discriminator is something the copy still carries.
`default_nettype none

// px_a — verbatim `gold` from uhdm2rtlil/test/genvar_loop_decl_3/dut.sv
module px_a(x, y);
    output reg [15:0] x, y;
    if (1) begin : gen
        integer x, y;
        genvar z;
        for (z = 0; z < 2; z++)
            if (z == 0)
                initial x = 10;
        assign y = x + 1;
    end
    initial x = gen.x;
    assign y = gen.y;
endmodule

// px_b — the same with the gen locals RENAMED so nothing shadows
module px_b(x, y);
    output reg [15:0] x, y;
    if (1) begin : gen
        integer p, q;
        genvar z;
        for (z = 0; z < 2; z++)
            if (z == 0)
                initial p = 10;
        assign q = p + 1;
    end
    initial x = gen.p;
    assign y = gen.q;
endmodule

// px_c — shadowing kept, but no module-level hierarchical READS of the locals
module px_c(x, y);
    output reg [15:0] x, y;
    if (1) begin : gen
        integer x, y;
        genvar z;
        for (z = 0; z < 2; z++)
            if (z == 0)
                initial x = 10;
        assign y = x + 1;
    end
    initial x = 0;
    assign y = 0;
endmodule
