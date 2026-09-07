// r10earl118 VERIFIER arm v2_fenceface -- THE NAMESAKE FENCE, every kind of
// enclosing declaration `bindVariable` can or cannot see:
//   module_inst  -> Variables() and Nets() ONLY (CompileStmt.cpp:3131-3144)
//   everything else -> recurse to VpiParent
// A namesake that bindVariable FINDS makes GOLDEN BIND, so the emitter must not
// suppress; a namesake it CANNOT find (a parameter, a generate-scope local, a
// typedef) must NOT lift the suppression.
// MEASUREMENT ONLY.  Legal SystemVerilog; scored against the GOLDEN database.
module v2_child (input logic [7:0] din, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : cb
    // n1 a namesake of a variable in the PARENT INSTANCE's body only
    logic [7:0] par_ns;  assign par_ns = $bits(par_ns)'({din[3:0], 4'b0});
    // n2 no namesake anywhere -- the law's own cell, inside a CHILD instance
    logic [7:0] plain_c; assign plain_c = $bits(plain_c)'({din[3:0], 4'b0});
  end
  assign o = cb[0].par_ns ^ cb[1].plain_c;
endmodule

module v2_fenceface #(parameter int prm_ns = 8) (
  input  logic [7:0] din,
  input  logic [7:0] prt_ns,          // a PORT namesake (its internal net IS in Nets())
  output logic [7:0] dout
);
  wire  [7:0] net_ns;                 // a module-body NET namesake -> bindVariable FINDS it
  logic [7:0] var_ns;                 // a module-body VARIABLE namesake -> FOUND
  logic [7:0] par_ns;                 // the child's namesake lives HERE
  typedef logic [7:0] typ_ns;         // a TYPEDEF namesake -> not a variable, NOT found
  localparam int loc_ns = 8;          // a LOCALPARAM namesake -> NOT found

  v2_child u_child (.din(din), .o());

  for (genvar k = 0; k < 2; k++) begin : ob
    logic [7:0] anc_ns;               // an ANCESTOR GENERATE scope's namesake
    assign anc_ns = din ^ 8'h55;
    for (genvar j = 0; j < 2; j++) begin : ib
      logic [7:0] net_ns;  assign net_ns  = $bits(net_ns)'({din[3:0], 4'b0});
      logic [7:0] var_ns;  assign var_ns  = $bits(var_ns)'({din[3:0], 4'b0});
      logic [7:0] prt_ns;  assign prt_ns  = $bits(prt_ns)'({din[3:0], 4'b0});
      logic [7:0] prm_ns;  assign prm_ns  = $bits(prm_ns)'({din[3:0], 4'b0});
      logic [7:0] loc_ns;  assign loc_ns  = $bits(loc_ns)'({din[3:0], 4'b0});
      logic [7:0] typ_ns;  assign typ_ns  = $bits(typ_ns)'({din[3:0], 4'b0});
      logic [7:0] anc_ns;  assign anc_ns  = $bits(anc_ns)'({din[3:0], 4'b0});
      logic [7:0] free_ns; assign free_ns = $bits(free_ns)'({din[3:0], 4'b0});
    end
  end

  assign net_ns = din | 8'h01;
  assign var_ns = din | 8'h02;
  assign par_ns = din | 8'h04;
  assign dout = net_ns ^ var_ns ^ par_ns ^ prt_ns ^
                ob[0].anc_ns ^ ob[1].ib[0].net_ns ^ ob[0].ib[1].var_ns ^
                ob[1].ib[0].prt_ns ^ ob[0].ib[1].prm_ns ^ ob[1].ib[0].loc_ns ^
                ob[0].ib[1].typ_ns ^ ob[1].ib[0].anc_ns ^ ob[0].ib[1].free_ns;
endmodule
