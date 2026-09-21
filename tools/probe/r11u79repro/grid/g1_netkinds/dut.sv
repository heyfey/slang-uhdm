// r11u75 g1 — LAW A: THE NET NAMESAKE, KIND BY KIND.  The pass-73 walk finds
// a NET namesake one scope out and declines to bind it because the store it
// consults (netMap) has no object for a net declared in an ENCLOSING GENERATE
// scope.  This arm asks WHICH net kinds golden binds there, and keeps the
// module-body net rows (already bound at the base) as the in-arm control.
module dut (input wire [31:0] pin_i, output logic [31:0] o);
  wire  [31:0] mb_plain;            // module-body plain net  (base binds)
  assign mb_plain = 32'd90;
  for (genvar i = 0; i < 1; i = i + 1) begin : G1
    wire  [31:0] e_plain;           // enclosing gen scope, plain net
    wire         e_scalar;          // enclosing gen scope, scalar net
    wire  [31:0] e_nda = 32'd7;     // enclosing gen scope, net-decl-assign
    reg   [31:0] e_reg;             // enclosing gen scope, a net-ified reg
    logic [31:0] e_var;             // enclosing gen scope, a VARIABLE control
    assign e_plain  = 32'd11;
    assign e_scalar = 1'b1;
    always @* e_reg = 32'd12;
    if (1) begin : G2
      logic [31:0] e_plain;  assign e_plain  = 32'd21;  // NET namesake, ranged
      logic        e_scalar; assign e_scalar = 1'b0;    // NET namesake, scalar
      logic [31:0] e_nda;    assign e_nda    = 32'd23;  // NET namesake, nda
      logic [31:0] e_reg;    assign e_reg    = 32'd24;  // net-ified reg namesake
      logic [31:0] e_var;    assign e_var    = 32'd25;  // VARIABLE namesake
      logic [31:0] mb_plain; assign mb_plain = 32'd26;  // 2 scopes out: UNBOUND
      wire  [31:0] tgt_net;  assign tgt_net  = 32'd27;  // gen-local NET TARGET
      logic [31:0] pin_i;    assign pin_i    = 32'd28;  // port namesake 2 out
    end
  end
  for (genvar j = 0; j < 1; j = j + 1) begin : H1
    // The one-hop home is the INSTANCE BODY here, whose nets DO reach netMap.
    logic [31:0] mb_plain; assign mb_plain = 32'd31;
    logic [31:0] pin_i;    assign pin_i    = 32'd32;
  end
  assign o = G1[0].G2.e_plain ^ G1[0].G2.e_scalar ^ G1[0].G2.e_nda
           ^ G1[0].G2.e_reg ^ G1[0].G2.e_var ^ G1[0].G2.mb_plain
           ^ G1[0].G2.tgt_net ^ G1[0].G2.pin_i
           ^ H1[0].mb_plain ^ H1[0].pin_i ^ mb_plain ^ G1[0].e_plain;
endmodule
