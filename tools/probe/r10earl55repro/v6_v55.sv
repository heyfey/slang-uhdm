// v55 adversarial arm 6 — the last SCOPE/DECLARATION forms that can carry a
// width-1 packed-vector replication fold: a body-scope `parameter` (not
// `localparam`, not in the port list), an INSTANCE ARRAY, a generate-if nested
// inside a generate-for, a $bits-derived width, a width computed to 1 from an
// override, and a 4-deep override chain.
// MEASURED (both views, both binaries): TO-GOLDEN 6 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  A body-scope `parameter`, BOTH elements of an INSTANCE ARRAY,
// a $bits-derived width and an N=1 override all land on golden; the N=3 sibling
// stays R1 and the gen-scope pair stays R6 (LOCATED logic_typespec, a different
// code path), byte-unchanged.
module v6_v55(input logic ext);
  s0_v55 u_s0 (.o(), .ext(ext));
  s1_v55 u_s1[1:0] (.o(), .ext(ext));
  s2_v55 u_s2 (.o(), .ext(ext));
  s3_v55 u_s3 (.o(), .ext(ext));
  s4_v55 #(.N(1)) u_s4a (.o(), .ext(ext));
  s4_v55 #(.N(3)) u_s4b (.o(), .ext(ext));
endmodule

// a body-scope `parameter` (overridable but never overridden)
module s0_v55 (output logic o, input logic ext);
  parameter logic [0:0] BP = {1{1'b1}};
  localparam logic [0:0] BL = {1{1'b1}};
  assign o = ext ^ BP[0] ^ BL[0];
endmodule

// instantiated as an INSTANCE ARRAY
module s1_v55 (output logic o, input logic ext);
  localparam logic [0:0] AR = {1{1'b1}};
  assign o = ext ^ AR[0];
endmodule

// generate-if nested inside a generate-for
module s2_v55 (output logic o, input logic ext);
  for (genvar g = 0; g < 2; g++) begin : gf
    if (g == 0) begin : gt
      localparam logic [0:0] NG = {1{1'b1}};
      wire wn = NG[0];
    end else begin : ge
      localparam logic [0:0] NH = {1{1'b1}};
      wire wn = NH[0];
    end
  end
  assign o = ext;
endmodule

// a $bits-derived width that evaluates to 1
module s3_v55 (output logic o, input logic ext);
  logic b1;
  localparam logic [$bits(b1)-1:0] BW = {$bits(b1){1'b1}};
  assign o = ext ^ BW[0];
endmodule

// the same declaration at width 1 and width 3 from an OVERRIDE
module s4_v55 #(parameter int N = 1) (output logic o, input logic ext);
  localparam logic [N-1:0] OV = {N{1'b1}};
  assign o = ext ^ OV[0];
endmodule
