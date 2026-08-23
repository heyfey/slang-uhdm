// r10v75 arm a1 -- INTERFACE and PROGRAM gen-scope processes (homes the
// implementer's grid does not carry), wildcard-imported package parameter.
package a1p;
  parameter int NB = 4;
  parameter bit [7:0] TB = 8'hA5;
endpackage

interface a1if #(parameter int W = 2) ();
  import a1p::*;
  logic [31:0] x, y, z, q;
  logic [7:0]  t;
  if (1) begin : gen_i
    always_comb x = {NB{1'b1}};          // A1_P1 gen-if in INTERFACE
    always_comb y = NB + 1;              // A1_P2
    always_comb t = {TB{1'b0}} | 8'h1;   // A1_P3 bit typespec origin
  end
  for (genvar g = 0; g < 2; g++) begin : gen_f
    always_comb z = {NB{1'b1}} & 32'hF;  // A1_P4 gen-for in INTERFACE
  end
  always_comb q = {NB{1'b1}};            // A1_P5 interface BODY (control)
endinterface

module a1sub (input logic [31:0] i0, output logic [31:0] o0);
  assign o0 = i0;
endmodule

module a1top;
  import a1p::*;
  logic [31:0] mb, pb;
  a1if #(3) u_if ();
  always_comb mb = {NB{1'b1}};           // A1_P6 module body (control)
  a1sub u_s (.i0(u_if.x), .o0());
endmodule
