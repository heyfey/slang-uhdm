// r10earl118 arm a3_fence118 -- THE FENCE: the shapes a CAST Rhs must NOT move.
//
// MEASUREMENT ONLY.  § genCaCastRhsOwnLocalLhsNoBind118 is OWN-SCOPE ONLY and
// applies only to a whole-name `ref_obj` target of a generate-scope
// `cont_assign`.  These rows are the ones a wider gate would break, and every
// one of them is legal SystemVerilog scored against the GOLDEN database.
interface a3_ifc118 (input logic clk);
  logic [7:0] i_vec;
  logic [7:0] i_src;
  for (genvar g = 0; g < 2; g++) begin : ig
    // f9 an INTERFACE generate scope, own-scope local, CAST Rhs
    logic [7:0] f9;
    assign f9 = $bits(f9)'({i_src[3:0], 4'b0});
    // f10 the same interface scope, NON-cast Rhs
    logic [7:0] f10;
    assign f10 = i_src ^ 8'h0f;
  end
  assign i_vec = ig[0].f9 ^ ig[1].f10;
endinterface

module a3_fence118 (
  input  logic       clk,
  input  logic [7:0] din,
  output logic [7:0] dout
);
  logic [7:0] mod_ns;      // a NAMESAKE of a generate-local name
  logic [7:0] mod_arr [0:3];
  logic [7:0] mod_tgt;

  a3_ifc118 u_ifc (.clk(clk));

  for (genvar g = 0; g < 2; g++) begin : fb
    // f1 a generate-local target whose NAME also exists in the module body,
    //    CAST Rhs.  `bindVariable` FINDS the module-body namesake, so
    //    Surelog's :2165 arm runs and golden BINDS -- the fence
    //    § genScopeCaPatNoFirstSize113 already decodes.
    logic [7:0] mod_ns;
    assign mod_ns = $bits(mod_ns)'({din[3:0], 4'b0});

    // f2 a MODULE-BODY target assigned from a generate scope, CAST Rhs
    if (g == 0) begin : one
      assign mod_tgt = $bits(mod_tgt)'({din[3:0], 4'b0});
    end

    // f3 a BIT-SELECT target with a CAST Rhs (never a plain ref_obj)
    logic [7:0] f3;
    assign f3[0] = |($bits(f3)'({din[3:0], 4'b0}));

    // f4 a PART-SELECT target with a CAST Rhs
    logic [7:0] f4;
    assign f4[3:0] = 4'({din[1:0], 2'b0});

    // f5 an UNPACKED-ARRAY element target with a CAST Rhs
    assign mod_arr[g] = $bits(din)'({din[3:0], 4'b0});

    // (the generate-scope PROCESS row lives in a4_procsegv118.sv.txt: it
    //  SEGFAULTS both binaries under --elabuhdm, see the README's R2)

    // f7 a generate-local target, cast Rhs, inside a NAMED IF-generate rather
    //    than a loop
    if (g < 2) begin : namedif
      logic [7:0] f7;
      assign f7 = $bits(f7)'({din[3:0], 4'b0});
    end

    // f8 a generate-local ENUM target with a cast Rhs
    typedef enum logic [7:0] { E_A = 8'h01, E_B = 8'h02 } e8_t;
    e8_t f8;
    assign f8 = e8_t'(din[7:0]);
  end

  assign mod_ns = din | 8'h01;
  assign dout = mod_ns ^ mod_tgt ^ fb[0].mod_ns ^ fb[1].f3 ^ fb[0].f4 ^
                mod_arr[0] ^ fb[0].namedif.f7 ^ fb[1].f8 ^
                u_ifc.i_vec;
endmodule
