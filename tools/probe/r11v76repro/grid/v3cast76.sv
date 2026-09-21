// VERIFIER arm v3 — THE CAST PASS-THRU'S UNMEASURED FACES.
// (a) the ARG-hop loop follows a DECLARED-TYPE parameter although the
//     outer hop loop refuses one; (b) hex digit CASE (the patch uppercases
//     the VpiValue but not the VpiDecompile; Surelog uppercases NEITHER);
//     (c) underscores; (d) an UPPERCASE base letter; (e) a >64-bit operand
//     under `unsigned'`; (f) `unsigned'` over a negative-patterned signed
//     decimal; (g) digits overflowing the declared width under a cast.
package v3;
  localparam int  K   = 6;
  localparam byte TB  = 8'd5;             // a DECLARED-TYPE parameter
  localparam      SDN = 8'sd200;          // implicit, negative pattern
  localparam      Q1  = signed'(TB);
  localparam      HQ1 = Q1;
  localparam      Q2  = unsigned'(16'hab);
  localparam      HQ2 = Q2;
  localparam      Q3  = unsigned'(16'ha_b);
  localparam      HQ3 = Q3;
  localparam      Q4  = signed'(16'sd5);
  localparam      HQ4 = Q4;
  localparam      Q5  = unsigned'(8'sd200);
  localparam      HQ5 = Q5;
  localparam      Q6  = $unsigned(4'd20);
  localparam      HQ6 = Q6;
  localparam      Q7  = signed'(16'sh1F);
  localparam      HQ7 = Q7;
  localparam      Q8  = unsigned'(96'hFFFFFFFFFFFFFFFFFFFFFFFF);
  localparam      HQ8 = Q8;
  localparam      Q9  = unsigned'(SDN);
  localparam      HQ9 = Q9;
  localparam      QA  = signed'(16'D5);
  localparam      HQA = QA;
  localparam      QB  = unsigned'(4'b1111);
  localparam      HQB = QB;
  localparam      QC  = signed'(8'sd200);
  localparam      HQC = QC;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] x01; logic [23:0] x02; logic [23:0] x03; logic [23:0] x04;
    logic [23:0] x05; logic [23:0] x06; logic [23:0] x07; logic [23:0] x08;
    logic [23:0] x09; logic [23:0] x10; logic [23:0] x11; logic [23:0] x12;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03; logic [23:0] d04;
    logic [23:0] d05; logic [23:0] e01;
  } v3_t;
  localparam v3_t A = '{bail: 8'hxA,
                        x01: HQ1, x02: HQ2, x03: HQ3, x04: HQ4, x05: HQ5,
                        x06: HQ6, x07: HQ7, x08: HQ8, x09: HQ9, x10: HQA,
                        x11: HQB, x12: HQC,
                        d01: signed'(TB), d02: unsigned'(16'hab),
                        d03: unsigned'(8'sd200), d04: signed'(16'sd5),
                        d05: 16'hab,
                        e01: K+1};
endpackage
module v3cast76 #(parameter v3::v3_t CA = v3::A)
                 (output logic [23:0] z00, output logic [23:0] z01,
                  output logic [23:0] z02, output logic [23:0] z03,
                  output logic [23:0] z04, output logic [23:0] z05,
                  output logic [23:0] z06, output logic [23:0] z07,
                  output logic [23:0] z08, output logic [23:0] z09,
                  output logic [23:0] z10, output logic [23:0] z11,
                  output logic [23:0] z12, output logic [23:0] z13,
                  output logic [23:0] z14, output logic [23:0] z15,
                  output logic [23:0] z16, output logic [23:0] z17,
                  output logic [23:0] z18);
  assign z00 = CA.bail; assign z01 = CA.x01; assign z02 = CA.x02;
  assign z03 = CA.x03;  assign z04 = CA.x04; assign z05 = CA.x05;
  assign z06 = CA.x06;  assign z07 = CA.x07; assign z08 = CA.x08;
  assign z09 = CA.x09;  assign z10 = CA.x10; assign z11 = CA.x11;
  assign z12 = CA.x12;  assign z13 = CA.d01; assign z14 = CA.d02;
  assign z15 = CA.d03;  assign z16 = CA.d04; assign z17 = CA.d05;
  assign z18 = CA.e01;
endmodule
