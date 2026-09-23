// r11u102 arm q5 — THE OTHER NET-DECLARATION HOMES of LAW B and LAW C: an
// INTERFACE body, a GENERATE block (if and for), and the RHS of a written
// `assign` onto a net whose type forces an implicit conversion.
package q5p;
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fs(int a); return a + 1; endfunction
  localparam int P512 = 512;
  localparam int CPX  = 2 ** 'x;
  localparam int CPC  = (3 < 4) ** 3;
endpackage
interface q5i;
  wire signed [63:0] iFP  = q5p::fp(3);
  wire signed [63:0] iFS  = q5p::fs(4);
  wire signed [63:0] iCL  = $clog2(q5p::P512);
  wire signed [63:0] iCPX = q5p::CPX;
  wire signed [63:0] iCPC = q5p::CPC;
endinterface
module q5_homes2102 #(parameter bit G = 1) (output logic [63:0] o);
  q5i u_if();
  if (G) begin : g_if
    wire signed [63:0] gFP  = q5p::fp(3);
    wire signed [63:0] gCL  = $clog2(q5p::P512);
    wire signed [63:0] gCPX = q5p::CPX;
    wire signed [63:0] gCPC = q5p::CPC;
  end
  for (genvar i = 0; i < 2; i++) begin : g_for
    wire signed [63:0] fFP = q5p::fp(i + 2);
    wire signed [63:0] fCL = $clog2(q5p::P512);
  end
  wire signed [63:0] mFP = q5p::fp(3);
  assign o = u_if.iFP ^ u_if.iFS ^ u_if.iCL ^ u_if.iCPX ^ u_if.iCPC ^
             g_if.gFP ^ g_if.gCL ^ g_if.gCPX ^ g_if.gCPC ^
             g_for[0].fFP ^ g_for[1].fFP ^ g_for[0].fCL ^ mFP;
endmodule
