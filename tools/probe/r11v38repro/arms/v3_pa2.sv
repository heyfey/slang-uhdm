// v11u38 adversarial arm 3 — law 2's boundary: shapes the gate must decline.
package pa3;
  parameter int W = 16;
  parameter     SUBW  = W - 4;        // INT:12
  parameter     XVAL  = 4'bx1;        // an UNKNOWN source
  parameter     SIGP  = -3;           // a written negative literal
  parameter string SP  = "abc";
  parameter real   RP  = 1.5;
  typedef enum logic [1:0] { EA = 2'd2 } e3_t;
  parameter e3_t EP = EA;             // an ENUM source
  parameter      TIMEP = 4;
endpackage

module v3_m import pa3::*; #(
    parameter int    P_SUBW = SUBW,
    parameter int    P_SIG  = SIGP,
    parameter        P_ENUM = EP,
    parameter string P_STR  = SP,
    parameter real   P_REAL = RP,
    parameter logic [3:0] P_X = XVAL
) ();
endmodule

module v3_gen import pa3::*; ();
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g
      localparam int GL = SUBW;       // inside a GENERATE scope
      logic [GL-1:0] w;
    end
  endgenerate
  if (1) begin : cond
    localparam int CL = SUBW;
  end
endmodule

module v3_top ();
  v3_m u0 ();
  v3_gen ug ();
endmodule
