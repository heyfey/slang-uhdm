// r10vearl113 (VERIFIER) arm v1 -- THE DECLARING-SCOPE AXIS, pushed past the
// implementer's s1.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
//
// § genScopeCaPatNoFirstSize113 suppresses the first-operand size stamp when
// the gen-scope cont-assign's TARGET is declared in that generate scope or in
// a generate block enclosing it (`genCaLhsGenLocal113`, a kind-before-identity
// scope walk).  Every cell here attacks that walk:
//   a1  target declared in the ENCLOSING gen block, assign in a NESTED one
//   a2  MODULE-BODY target, assign at generate DEPTH 2 (the fence, deeper)
//   a3  SHADOWING: the same name declared in the module body AND gen-locally
//   a4  the gen-if ELSE branch
//   a5  an UNNAMED generate block
//   a6  a COMMA-LIST assign carrying one gen-local and one module-body target
// Every cell carries an ENUM member so Surelog models the object as a
// struct_var and UHDM's cont_assign::DeepClone actually flattens the pattern.
package pv113;
  typedef enum logic [2:0] { VA = 3'h0, VB = 3'h4 } ve_e;
  typedef struct packed {
    logic       v;
    ve_e        o;
    logic [7:0] d;
  } vs_t;
endpackage

module v1_decl113 #(parameter int M = 3) (
  input  logic       clk,
  input  pv113::vs_t tl_i [M],
  input  logic [7:0] d_i,
  output logic       y_o
);
  // a1  TARGET DECLARED IN THE ENCLOSING GENERATE BLOCK
  for (genvar i = 0; i < M; i++) begin : gen_a1o
    pv113::vs_t a1_outer;
    if (1) begin : gen_a1i
      assign a1_outer = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
    end
  end

  // a2  MODULE-BODY TARGET, assign at generate DEPTH 2
  pv113::vs_t a2_mod;
  for (genvar i = 0; i < 1; i++) begin : gen_a2o
    if (1) begin : gen_a2i
      assign a2_mod = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
    end
  end

  // a3  SHADOWING -- the module-body cell is the negative control beside it
  pv113::vs_t sh_v;
  assign sh_v = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  for (genvar i = 0; i < M; i++) begin : gen_a3
    pv113::vs_t sh_v;
    assign sh_v = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // a4  THE GEN-IF ELSE BRANCH
  if (M < 2) begin : gen_a4t
    pv113::vs_t a4t;
    assign a4t = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  end else begin : gen_a4e
    pv113::vs_t a4e;
    assign a4e = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  end

  // a5  AN UNNAMED GENERATE BLOCK
  for (genvar i = 0; i < 2; i++) begin
    pv113::vs_t a5_un;
    assign a5_un = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // a6  A COMMA-LIST ASSIGN: gen-local target AND module-body target in ONE
  //     statement (the guard must be per cont_assign, not per statement)
  pv113::vs_t a6_mod;
  for (genvar i = 0; i < 1; i++) begin : gen_a6
    pv113::vs_t a6_loc;
    assign a6_loc = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i },
           a6_mod = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  end

  // a7  THE NAME ALSO EXISTS IN THE PARENT MODULE (one hierarchy level up):
  //     `bindVariable` recurses PAST module_inst into `scope->VpiParent()`,
  //     so the walk does not stop at this module's own body.  Measured, not
  //     assumed: the leaf's gen-local `a7_nm` is declared nowhere in the leaf.
  pv113::vs_t a7_nm;
  v1_leaf113 u_a7 (.tl_i(tl_i), .d_i(d_i));

  assign y_o = sh_v.v ^ a2_mod.v ^ a6_mod.v ^ a7_nm.v;
endmodule

module v1_leaf113 (
  input  pv113::vs_t tl_i [3],
  input  logic [7:0] d_i
);
  for (genvar i = 0; i < 2; i++) begin : gen_a7
    pv113::vs_t a7_nm;
    assign a7_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end
endmodule
