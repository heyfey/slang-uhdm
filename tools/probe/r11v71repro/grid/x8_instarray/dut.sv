// v11u71 x8 — THE INSTANCE ARRAY HOP.  `bindVariable` recurses through
// `scope->VpiParent()`, which crosses a module/interface ARRAY without looking
// in it.  Our walk hops `parentInstance->getParentScope()`, which for an array
// member is the InstanceArray scope.  One leaf, instantiated SINGLY and as an
// ARRAY, with the namesake in dut's body.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module leaf #(parameter p::cfg_t C = p::LIT) (output logic [31:0] o);
  if (1) begin : g
    logic [31:0] anc;          // namesake `anc` lives in dut's body, 5 bits
    assign anc = C.n;
  end
  assign o = g.anc;
endmodule

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o);
  logic [4:0] anc;             // the ancestor-body namesake, 5 bits
  logic [31:0] s0, s1, s2;
  leaf #(.C(CFG)) u_one  (.o(s0));     // SINGLE instance
  leaf #(.C(CFG)) u_arr [0:1] (.o({s1, s2}));  // instance ARRAY
  assign o = s0 ^ s1 ^ s2 ^ {27'd0, anc};
  assign anc = 5'd0;
endmodule
