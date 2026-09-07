// r10vearl113 (VERIFIER) arm v6 -- THE NAME WALK ITSELF.  MEASUREMENT ONLY.
//
// Surelog's `bindVariable` (CompileStmt.cpp:3089-3148) looks the Lhs NAME up in
// each enclosing scope's own `Variables()` and `Nets()` -- and in NOTHING else:
// no parameters, no typedefs, no instances -- skipping `gen_scope` entirely and
// recursing past `module_inst`.  Each cell below is one clause of that
// sentence, so the fix's lookup can be wrong in only one direction per cell:
//   g1  the namesake is a module-body PARAMETER      -> golden must NOT size
//   g2  the namesake is a module-body NET (wire)     -> golden SIZES
//   g3  the namesake is declared AFTER the generate  -> golden SIZES
//   g4  the namesake is in an ENCLOSING GEN BLOCK    -> golden must NOT size
//   g5  the namesake is the module's own PORT        -> golden SIZES
//   g6  no namesake anywhere (the plain head shape)  -> golden must NOT size
package pv6113;
  typedef enum logic [2:0] { QA = 3'h0, QB = 3'h4 } qe_e;
  typedef struct packed {
    logic       v;
    qe_e        o;
    logic [7:0] d;
  } qs_t;
endpackage

module v6_name113 #(parameter int M = 2) (
  input  logic        clk,
  input  pv6113::qs_t tl_i [M],
  input  logic [7:0]  d_i,
  input  pv6113::qs_t g5_nm,
  output logic        y_o
);
  // g1  A PARAMETER of the same name -- bindVariable never looks at parameters
  localparam int g1_nm = 7;
  for (genvar i = 0; i < M; i++) begin : gen_g1
    pv6113::qs_t g1_nm;
    assign g1_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // g2  A NET of the same name in the module body
  wire pv6113::qs_t g2_nm;
  assign g2_nm = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };
  for (genvar i = 0; i < M; i++) begin : gen_g2
    pv6113::qs_t g2_nm;
    assign g2_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // g4  A NAMESAKE IN AN ENCLOSING GENERATE BLOCK -- the walk must skip it
  for (genvar i = 0; i < M; i++) begin : gen_g4o
    pv6113::qs_t g4_nm;
    assign g4_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
    if (1) begin : gen_g4i
      pv6113::qs_t g4_nm;
      assign g4_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
    end
  end

  // g5  THE MODULE'S OWN PORT is the namesake
  for (genvar i = 0; i < M; i++) begin : gen_g5
    pv6113::qs_t g5_nm;
    assign g5_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // g6  NO NAMESAKE ANYWHERE -- the plain head shape, the positive control
  for (genvar i = 0; i < M; i++) begin : gen_g6
    pv6113::qs_t g6_nm;
    assign g6_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end

  // g3  THE NAMESAKE IS DECLARED AFTER THE GENERATE BLOCK
  for (genvar i = 0; i < M; i++) begin : gen_g3
    pv6113::qs_t g3_nm;
    assign g3_nm = '{ v: tl_i[i].v, o: tl_i[i].o, d: d_i };
  end
  pv6113::qs_t g3_nm;
  assign g3_nm = '{ v: tl_i[0].v, o: tl_i[0].o, d: d_i };

  assign y_o = g2_nm.v ^ g3_nm.v ^ g5_nm.v ^ int'(g1_nm);
endmodule
