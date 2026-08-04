// r10earl3 y.sv — UNSIZED BASED LITERAL in a syntax-emitted (module-DEF
// gen-block) expression.  emitSyntaxExpr's IntegerVectorExpression arm gives
// every unsized literal SIZE 64; golden reads SIZE 0 for `'b0`.
// Corpus: prim_fifo_sync.sv:145 `assign rdata = empty ? 'b0 : rdata_int;`
// — 13 Earlgrey AllModules def entries.  Read the uhdmallModules view.
module ysub #(parameter int unsigned Depth = 4) (input logic sel,
                                                 input  logic [7:0] a,
                                                 output logic [7:0] o0,
                                                 output logic [7:0] o1,
                                                 output logic [7:0] o2,
                                                 output logic [7:0] o3,
                                                 output logic [7:0] o4,
                                                 output logic [7:0] o5,
                                                 output logic [7:0] o6,
                                                 output logic [7:0] o7);
  if (Depth != 0) begin : gen_norm
    assign o0 = sel ? 'b0 : a;   // single binary digit, 0
    assign o1 = sel ? 'b1 : a;   // single binary digit, 1
    assign o2 = sel ? 'b101 : a; // multi-digit binary
    assign o3 = sel ? 'h3 : a;   // unsized hex
    assign o4 = sel ? 'o7 : a;   // unsized octal
    assign o5 = sel ? 'd9 : a;   // unsized decimal
    assign o6 = sel ? 8'hab : a; // SIZED control
    assign o7 = sel ? 'bx : a;   // unsized binary x
  end
endmodule

module ytop (input logic sel, input logic [7:0] a,
             output logic [7:0] o0, output logic [7:0] o1,
             output logic [7:0] o2, output logic [7:0] o3,
             output logic [7:0] o4, output logic [7:0] o5,
             output logic [7:0] o6, output logic [7:0] o7);
  ysub #(.Depth(4)) u(.sel(sel), .a(a), .o0(o0), .o1(o1), .o2(o2), .o3(o3),
                      .o4(o4), .o5(o5), .o6(o6), .o7(o7));
endmodule
