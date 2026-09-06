// r10v104 va3 -- MORE elaborator-evaluated reader positions.  MEASUREMENT ONLY.
module subw104 #(parameter P = 0) (output logic z); assign z = |P; endmodule

module m_s1 (output logic o);        // packed STRUCT member range
  localparam logic [4-1:0] X = {4{1'b1}};
  typedef struct packed { logic [X[0]:0] f; } st_t;
  st_t s1; assign s1 = '0; assign o = s1.f[0];
endmodule

module m_s2 (output logic o);        // FUNCTION-local variable range
  localparam logic [4-1:0] X = {4{1'b1}};
  function automatic logic g2(input logic a);
    logic [X[0]:0] lv; lv = '0; return a ^ lv[0];
  endfunction
  assign o = g2(1'b0);
endmodule

module m_s3 (output logic o);        // UNPACKED array dimension
  localparam logic [4-1:0] X = {4{1'b1}};
  logic w3 [X[0]:0];
  assign w3[0] = 1'b0;
  assign o = w3[0];
endmodule

module m_s4 (output logic o);        // a localparam in a GENERATE SCOPE reads it (bare)
  localparam logic [4-1:0] X = {4{1'b1}};
  if (1) begin : gs
    localparam int Y4 = X[0];
    logic w4; assign w4 = Y4[0];
  end
  assign o = gs.w4;
endmodule

module m_s5 (output logic o);        // a localparam in a GENERATE SCOPE used as a RANGE
  localparam logic [4-1:0] X = {4{1'b1}};
  if (1) begin : gs
    logic [X[0]:0] w5; assign w5 = '0;
  end
  assign o = gs.w5[0];
endmodule

module m_s6 (output logic o);        // the parameter's own value used as another param's DIMENSION
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam logic [X[0]:0] Y6 = '0;
  assign o = Y6[0];
endmodule

module m_s7 (output logic o);        // a CHILD instance's port width via override reading a SELECT (control: covered)
  localparam logic [4-1:0] X = {4{1'b1}};
  logic z7; subw104 #(.P(X[0])) u7 (.z(z7));
  assign o = z7;
endmodule

module m_s8 (output logic o);        // genvar loop INITIAL value
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] o8;
  for (genvar i = X[0]-1; i < 2; i = i + 1) begin : g8 assign o8[i] = 1'b0; end
  assign o = o8[0];
endmodule

module m_s9 (output logic o);        // a REPEAT count in a procedural block (control)
  localparam logic [4-1:0] X = {4{1'b1}};
  logic o9;
  always_comb begin o9 = 1'b0; end
  assign o = o9 ^ X[0];
endmodule

module m_sa (output logic o);        // a CAST using the parameter's value at module level
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [7:0] wa; assign wa = 8'(X[0]);
  assign o = wa[0];
endmodule

module va3_more104(output logic o);
  logic [10:0] q;
  m_s1 u_s1 (.o(q[0]));  m_s2 u_s2 (.o(q[1]));  m_s3 u_s3 (.o(q[2]));
  m_s4 u_s4 (.o(q[3]));  m_s5 u_s5 (.o(q[4]));  m_s6 u_s6 (.o(q[5]));
  m_s7 u_s7 (.o(q[6]));  m_s8 u_s8 (.o(q[7]));  m_s9 u_s9 (.o(q[8]));
  m_sa u_sa (.o(q[9]));
  assign q[10] = 1'b0;
  assign o = |q;
endmodule
