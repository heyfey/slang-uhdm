// r10earl104 g6 -- THE MIXTURES.  MEASUREMENT ONLY.
// The cells that separate a PER-PARAMETER reader test from a per-module one,
// and the reader positions that must NOT count.
module g6_mix104(input logic ext, output logic o);
  m_f1 u_f1(.ext(ext), .o()); m_f2 u_f2(.ext(ext), .o());
  m_f3 u_f3(.ext(ext), .o()); m_f4 u_f4(.ext(ext), .o());
  m_f5 u_f5(.ext(ext), .o()); m_f6 u_f6(.ext(ext), .o());
  assign o = ext;
endmodule
// f1: TWO identically typed params, only ONE read by a module-level cont-assign.
//     The reader test must split them (earl55 a3 d5_55's shape).
module m_f1(input logic ext, output logic o);
  localparam logic [7:0] XR = {8{1'b1}};
  localparam logic [7:0] XU = {8{1'b1}};
  assign o = |XR;
endmodule
// f2: read ONLY from an UNINSTANTIATED generate branch's BODY.
module m_f2(input logic ext, output logic o);
  localparam logic [7:0] X = {8{1'b1}};
  if (1'b0) begin : dead assign o = |X; end else begin : live assign o = 1'b0; end
endmodule
// f3: read ONLY from an UNINSTANTIATED branch's CONDITION is impossible; here
//     the CONDITION reads the param and BOTH branches exist.
module m_f3(input logic ext, output logic o);
  localparam logic [7:0] X = {8{1'b1}};
  if (X[0]) begin : t assign o = 1'b1; end else begin : f assign o = 1'b0; end
endmodule
// f4: BOTH a gen-scope bare read AND a module-level SELECT.
module m_f4(input logic ext, output logic o);
  localparam logic [7:0] X = {8{1'b1}};
  logic a;
  assign a = X[1];
  for (genvar k = 0; k < 2; k++) begin : g logic w; assign w = |X; end
  assign o = a;
endmodule
// f5: read by a GENERATE-CASE item.
module m_f5(input logic ext, output logic o);
  localparam logic [7:0] X = {8{1'b1}};
  case (X[1:0])
    2'b11: begin : ca assign o = 1'b1; end
    default: begin : cb assign o = 1'b0; end
  endcase
endmodule
// f6: read ONLY inside a FUNCTION body called from a cont-assign.
module m_f6(input logic ext, output logic o);
  localparam logic [7:0] X = {8{1'b1}};
  function automatic logic f6_104(); return |X; endfunction
  assign o = f6_104();
endmodule
