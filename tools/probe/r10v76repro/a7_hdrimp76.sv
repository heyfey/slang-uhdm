// r10v76 arm a7 -- the MODULE-HEADER import, which is the CORPUS's own shape
// (`module flash_phy_core import flash_phy_pkg::*; #(...) (...)`).  V-FIX
// v76 (a) tests the module BODY scope for the providing import, so the header
// form has to land in the SAME scope or the corpus head comes back.  Row H is
// the header form, row B the body form, row N the negative control (a header
// import of a DIFFERENT package while the read comes from a gen-block import).
package v76p7;
  parameter int NB = 4;
endpackage
package v76q7;
  parameter int QB = 11;
endpackage

module v76hdr import v76p7::*; #(parameter int P = 2) (output logic [31:0] o);
  logic [31:0] h1;
  if (P > 0) begin : gh_a
    always_comb begin
      h1 = '0;
      for (int i = 0; i < NB; i++) h1 = h1 + 1;   // HEADER import -> REFUSE
    end
  end
  assign o = h1;
endmodule

module v76bdy #(parameter int P = 2) (output logic [31:0] o);
  import v76p7::*;                                 // BODY import -> REFUSE
  logic [31:0] b1;
  if (P > 0) begin : gb_a
    always_comb begin
      b1 = '0;
      for (int i = 0; i < NB; i++) b1 = b1 + 1;
    end
  end
  assign o = b1;
endmodule

module v76hdrn import v76p7::*; #(parameter int P = 2) (output logic [31:0] o);
  logic [31:0] n1;
  if (P > 0) begin : gn_a
    import v76q7::*;                               // GEN-BLOCK import -> FOLD
    always_comb begin
      n1 = '0;
      for (int i = 0; i < QB; i++) n1 = n1 + 1;    // from the gen block
      for (int i = 0; i < NB; i++) n1 = n1 + 1;    // from the module header
    end
  end
  assign o = n1;
endmodule

module v76hdrtop (output logic [31:0] o1, output logic [31:0] o2, output logic [31:0] o3);
  v76hdr  #(2) u_h (.o(o1));
  v76bdy  #(2) u_b (.o(o2));
  v76hdrn #(2) u_n (.o(o3));
endmodule
