// § ndaSizeFoldReach219 — the $size shapes golden folds in a net-declaration initializer: element kinds and a dimension argument
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4,
            output logic [7:0] o5, output logic [7:0] o6, output logic [7:0] o7);
  typedef struct { logic a; } us_t;
  us_t        su1 [4];
  string      st [3];
  logic [1:0] m [2][3];
  logic [5:0] v;
  logic [3:0][1:0] pv;
  wire [7:0] w1 = $size(su1);
  wire [7:0] w2 = $size(st);
  wire [7:0] w3 = $size(m, 1);
  wire [7:0] w4 = $size(v, 1);
  wire [7:0] w5 = $size(pv);
  wire [7:0] w6 = $size(pv, 2);
  wire [7:0] w7 = $size(m, 3);
  assign o1 = w1;
  assign o2 = w2;
  assign o3 = w3;
  assign o4 = w4;
  assign o5 = w5;
  assign o6 = w6;
  assign o7 = w7;
endmodule
